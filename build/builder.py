import shutil
import argparse
import subprocess
import os
import glob
import sys

# === STEP 0: Get the project name from command-line arguments ===
if len(sys.argv) < 2:
    print("❌ Please specify the project name. Example:")
    print("   python builder.py my_project -all")
    sys.exit(1)

project = sys.argv[1]        # First argument: project name
sys.argv.pop(1)              # Remove it so -hw/-sim/-gui work with argparse

# === STEP 0.5: Clean target directory ===
def run_clean():
    print(f"\n🧹 Cleaning build files for: {project}")
    if not os.path.exists(TARGET_DIR):
        print("ℹ️  Nothing to clean — target folder does not exist.")
        return

    removed_any = False
    for f in os.listdir(TARGET_DIR):
        path = os.path.join(TARGET_DIR, f)
        try:
            if os.path.isfile(path) or os.path.islink(path):
                os.remove(path)
                print(f"✔️  Deleted: {f}")
                removed_any = True
            elif os.path.isdir(path):
                shutil.rmtree(path)
                print(f"✔️  Deleted folder: {f}")
                removed_any = True
        except Exception as e:
            print(f"❌ Failed to delete {f}: {e}")

    if not removed_any:
        print("ℹ️  Target folder was already empty.")

# === STEP 1: Define folder structure and file names ===
SRC_DIR = "../source"
VERIF_DIR = "../verif"
MACRO_DIR = f"{SRC_DIR}/common"
TARGET_DIR = f"../target/{project}"

TOP_MODULE = f"{project}.sv"
TB_MODULE = f"tb_{project}.sv"
OUT_EXEC = f"{project}.out"
VCD_FILE = f"{project}.vcd"


# === STEP 2: Check if required source and testbench files exist ===
def check_required_files():
    missing = []
    top_path = f"{SRC_DIR}/{TOP_MODULE}"
    tb_path = f"{VERIF_DIR}/{TB_MODULE}"

    if not os.path.exists(top_path):
        missing.append(top_path)
    if not os.path.exists(tb_path):
        missing.append(tb_path)

    if missing:
        print("❌ Missing required file(s):")
        for m in missing:
            print(f"   - {m}")
        sys.exit(1)

# === STEP 3: Compile the SystemVerilog design + testbench + macros ===
def run_hw():
    print(f"\n🛠️  Compiling project: {project}")
    print(f"🔍 Top: {TOP_MODULE}, Testbench: {TB_MODULE}")
    os.makedirs(TARGET_DIR, exist_ok=True)
    check_required_files()

    macro_files = glob.glob(f"{MACRO_DIR}/*.sv")

    compile_cmd = [
        "iverilog",
        "-g2012",
        "-I", MACRO_DIR,  # 🔥 THIS LINE tells iverilog where to find includes
        "-o", f"{TARGET_DIR}/{OUT_EXEC}",
        f"{SRC_DIR}/{TOP_MODULE}",
        f"{VERIF_DIR}/{TB_MODULE}",
    ] + macro_files

    try:
        subprocess.run(compile_cmd, check=True)
        print("✅ Compilation successful")
    except subprocess.CalledProcessError:
        print("❌ Compilation failed")
        sys.exit(1)


# === STEP 4: Run simulation and back up existing wave.vcd ===
def run_sim():
    print("\n🚀 Running simulation...")
    vcd_path = f"{TARGET_DIR}/{VCD_FILE}"
    prev_vcd_path = vcd_path.replace(".vcd", "_prev.vcd")

    # Backup existing VCD if it exists
    if os.path.exists(vcd_path):
        os.rename(vcd_path, prev_vcd_path)
        print(f"📦 Backed up previous VCD to: {prev_vcd_path}")

    sim_cmd = ["vvp", f"{TARGET_DIR}/{OUT_EXEC}"]

    try:
        subprocess.run(sim_cmd, check=True)
        print("✅ Simulation completed")
    except subprocess.CalledProcessError:
        print("❌ Simulation failed")
        sys.exit(1)

# === STEP 5: Launch GTKWave ===
def run_gui():
    print("\n🖥️ Launching GTKWave...")
    vcd_path = f"{TARGET_DIR}/{VCD_FILE}"

    if not os.path.exists(vcd_path):
        print(f"❌ VCD file not found: {vcd_path}")
        sys.exit(1)

    subprocess.run(["gtkwave", vcd_path])

# === STEP 6: CLI handling ===
def main():
    parser = argparse.ArgumentParser(description="SystemVerilog Builder for any project")
    parser.add_argument("-clean", action="store_true", help="Delete all generated files for the project")
    parser.add_argument("-hw", action="store_true", help="Compile only")
    parser.add_argument("-sim", action="store_true", help="Run simulation (requires -hw)")
    parser.add_argument("-gui", action="store_true", help="Open GTKWave (requires -hw and -sim)")
    parser.add_argument("-all", action="store_true", help="Run compile + sim + GTKWave")

    args = parser.parse_args()

    if args.clean:
         run_clean()
    # Optional: exit after cleaning, or continue if combined with -hw/-sim/-gui
    if not (args.hw or args.sim or args.gui or args.all):
        return

   
    # Handle -all (runs everything in correct order)
    if args.all:
        run_hw()
        run_sim()
        run_gui()
        return

    # Enforce flag dependencies
    if args.gui and (not args.hw or not args.sim):
        print("❌ GTKWave (-gui) requires both -hw and -sim")
        sys.exit(1)

    if args.sim and not args.hw:
        print("❌ Simulation (-sim) requires -hw (compile) first")
        sys.exit(1)

    # Execute steps in correct order
    if args.hw:
        run_hw()
        if args.sim:
            run_sim()
        if args.gui:
            run_gui()

    # If no flags passed
    if not (args.hw or args.sim or args.gui or args.all):
        print("ℹ️ Use -hw, -sim, -gui, or -all to run a build step")

if __name__ == "__main__":
    main()
