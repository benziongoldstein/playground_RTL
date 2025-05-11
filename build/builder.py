import shutil
import argparse
import subprocess
import os
import sys

# === STEP 0: Find MODEL_ROOT (project root) ===
def find_model_root():
    # Use environment variable if set
    env_root = os.environ.get('MODEL_ROOT')
    if env_root:
        return os.path.abspath(env_root)
    # Otherwise, walk up from current directory to find 'build' directory
    cur = os.path.abspath(os.getcwd())
    while cur != '/':
        if os.path.isdir(os.path.join(cur, 'build')):
            return cur
        cur = os.path.dirname(cur)
    raise RuntimeError("MODEL_ROOT not found (no 'build' directory in any parent)")

MODEL_ROOT = find_model_root()

# === STEP 0.5: Get the project name from command-line arguments ===
if len(sys.argv) < 2:
    print("❌ Please specify the project name. Example:")
    print("   python build/builder.py my_project -all")
    sys.exit(1)

project = sys.argv[1]        # First argument: project name
sys.argv.pop(1)              # Remove it so -hw/-sim/-gui work with argparse

# === STEP 1: Define folders and file paths relative to MODEL_ROOT ===
SRC_DIR = os.path.join(MODEL_ROOT, "source")
VERIF_DIR = os.path.join(MODEL_ROOT, "verif")
TARGET_DIR = os.path.join(MODEL_ROOT, "target", project)
F_FILE = os.path.join(VERIF_DIR, project, f"{project}_list.f")
OUT_EXEC = f"{project}.out"
VCD_FILE = f"{project}.vcd"

# === STEP 2: Clean target directory ===
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

# === STEP 3: Compile using file list ===
def run_hw():
    print(f"\n🛠️  Compiling project: {project}")
    print(f"🔍 Using file list: {F_FILE}")
    os.makedirs(TARGET_DIR, exist_ok=True)

    if not os.path.exists(F_FILE):
        print(f"❌ Missing file list: {F_FILE}")
        sys.exit(1)

    # Use the -f flag to directly include the file list instead of parsing it manually
    compile_cmd = [
        "iverilog",
        "-g2012",
        "-f", F_FILE,
        "-o", os.path.join(TARGET_DIR, OUT_EXEC)
    ]

    print("Compile command:", " ".join(compile_cmd))  # Optional: for debugging

    try:
        subprocess.run(compile_cmd, check=True)
        print("✅ Compilation successful")
    except subprocess.CalledProcessError:
        print("❌ Compilation failed")
        sys.exit(1)

# === STEP 4: Run simulation ===
def run_sim():
    print("\n🚀 Running simulation...")
    vcd_path = os.path.join(TARGET_DIR, VCD_FILE)
    prev_vcd_path = vcd_path.replace(".vcd", "_prev.vcd")

    if os.path.exists(vcd_path):
        os.rename(vcd_path, prev_vcd_path)
        print(f"📦 Backed up previous VCD to: {prev_vcd_path}")

    sim_cmd = ["vvp", os.path.join(TARGET_DIR, OUT_EXEC)]

    try:
        subprocess.run(sim_cmd, check=True)
        print("✅ Simulation completed")
    except subprocess.CalledProcessError:
        print("❌ Simulation failed")
        sys.exit(1)

# === STEP 5: Launch GTKWave ===
def run_gui():
    print("\n🖥️ Launching GTKWave...")
    vcd_path = os.path.join(TARGET_DIR, VCD_FILE)

    if not os.path.exists(vcd_path):
        print(f"❌ VCD file not found: {vcd_path}")
        sys.exit(1)

    subprocess.run(["gtkwave", vcd_path])

# === STEP 6: CLI Handling ===
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
        if not (args.hw or args.sim or args.gui or args.all):
            return

    if args.all:
        run_hw()
        run_sim()
        run_gui()
        return

    if args.gui and (not args.hw or not args.sim):
        print("❌ GTKWave (-gui) requires both -hw and -sim")
        sys.exit(1)

    if args.sim and not args.hw:
        print("❌ Simulation (-sim) requires -hw (compile) first")
        sys.exit(1)

    if args.hw:
        run_hw()
        if args.sim:
            run_sim()
        if args.gui:
            run_gui()

    if not (args.hw or args.sim or args.gui or args.all):
        print("ℹ️ Use -hw, -sim, -gui, or -all to run a build step")

if __name__ == "__main__":
    main()