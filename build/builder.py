#!/usr/bin/env python3
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
        print(f"[DEBUG] Using MODEL_ROOT from environment: {env_root}")
        return os.path.abspath(env_root)
    # Try git rev-parse
    try:
        git_root = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], stderr=subprocess.DEVNULL).decode().strip()
        if git_root:
            print(f"[DEBUG] Using MODEL_ROOT from git: {git_root}")
            return os.path.abspath(git_root)
    except Exception:
        pass
    # Otherwise, walk up from current directory to find 'build' directory
    cur = os.path.abspath(os.getcwd())
    while cur != '/':
        if os.path.isdir(os.path.join(cur, 'build')):
            print(f"[DEBUG] Using MODEL_ROOT by directory walk: {cur}")
            return cur
        cur = os.path.dirname(cur)
    raise RuntimeError("MODEL_ROOT not found (no 'build' directory in any parent, and not a git repo)")

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
APP_DIR = os.path.join(MODEL_ROOT, "app")
F_FILE = os.path.join(VERIF_DIR, project, f"{project}_list.f")
OUT_EXEC = f"{project}.out"
VCD_FILE = f"{project}.vcd"

print(f"[DEBUG] MODEL_ROOT: {MODEL_ROOT}")
print(f"[DEBUG] File list: {F_FILE}")

# Check if the IP exists
def check_ip_exists(ip_name):
    verif_ip_dir = os.path.join(VERIF_DIR, ip_name)
    if not os.path.exists(verif_ip_dir):
        print(f"❌ No IP called {ip_name}")
        sys.exit(1)
    return True

# Validate that the IP exists
check_ip_exists(project)

# === NEW STEP: Compile app code ===
def run_app(use_asm_mode=False):
    print(f"\n🛠️  Compiling RISC-V application")
    if not os.path.exists(APP_DIR):
        print(f"❌ App directory not found: {APP_DIR}")
        sys.exit(1)
    
    try:
        # Change to app directory
        os.chdir(APP_DIR)
        
        # Run make clean
        print("Cleaning app build files...")
        subprocess.run(["make", "clean"], check=True)
        
        # Run make with appropriate target
        if use_asm_mode:
            print("Building assembly-only test...")
            subprocess.run(["make", "asm"], check=True)
        else:
            print("Building RISC-V C application...")
            subprocess.run(["make"], check=True)
        
        # Copy the inst_mem.sv file to the verification directory
        inst_mem_src = os.path.join(TARGET_DIR, "test_inst_mem.sv" if use_asm_mode else "inst_mem.sv")
        inst_mem_dst = os.path.join(VERIF_DIR, project, "inst_mem.sv")
        
        if os.path.exists(inst_mem_src):
            print(f"Copying memory file to {inst_mem_dst}...")
            shutil.copy2(inst_mem_src, inst_mem_dst)
            print("✅ App compilation successful")
        else:
            print(f"❌ Memory file not found: {inst_mem_src}")
            sys.exit(1)
        
        # Return to the model root
        os.chdir(MODEL_ROOT)
    except subprocess.CalledProcessError:
        print("❌ App compilation failed")
        os.chdir(MODEL_ROOT)  # Ensure we return to model root even on error
        sys.exit(1)

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

    sim_cmd = ["vvp", os.path.join(TARGET_DIR, OUT_EXEC), f"+VCD={vcd_path}"]

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
    parser.add_argument("-app", action="store_true", help="Compile RISC-V application before hardware compilation")
    parser.add_argument("-asm", action="store_true", help="Use assembly-only mode for RISC-V application")
    parser.add_argument("-hw", action="store_true", help="Compile only")
    parser.add_argument("-sim", action="store_true", help="Run simulation (requires -hw)")
    parser.add_argument("-gui", action="store_true", help="Open GTKWave (requires -hw and -sim)")
    parser.add_argument("-all", action="store_true", help="Run compile + sim + GTKWave")
    parser.add_argument("-all-app", action="store_true", help="Run app compilation + compile + sim + GTKWave")
    parser.add_argument("-all-asm", action="store_true", help="Run assembly compilation + compile + sim + GTKWave")

    args = parser.parse_args()

    if args.clean:
        run_clean()
        if not (args.hw or args.sim or args.gui or args.all or args.all_app or args.app or args.all_asm or args.asm):
            return

    if args.all_asm:
        # Assembly-only mode followed by all steps
        run_app(use_asm_mode=True)
        run_hw()
        run_sim()
        run_gui()
        return

    if args.all_app:
        # First compile the app, then do everything else
        run_app(use_asm_mode=False)
        run_hw()
        run_sim()
        run_gui()
        return

    if args.all:
        run_hw()
        run_sim()
        run_gui()
        return

    if args.app:
        # Normal app mode (C + assembly)
        run_app(use_asm_mode=args.asm)

    if args.asm and not args.app:
        # Assembly-only mode without app flag
        run_app(use_asm_mode=True)

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

    if not (args.hw or args.sim or args.gui or args.all or args.all_app or args.app or args.all_asm or args.asm):
        print("ℹ️ Use -app, -asm, -hw, -sim, -gui, -all, -all-app, or -all-asm to run a build step")

if __name__ == "__main__":
    main()