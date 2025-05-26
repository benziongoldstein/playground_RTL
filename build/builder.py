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

# === STEP 3: Compile using QuestaSim vlog ===
def run_hw():
    print(f"\n🛠️  Compiling project: {project}")
    print(f"🔍 Using file list: {F_FILE}")
    os.makedirs(TARGET_DIR, exist_ok=True)

    if not os.path.exists(F_FILE):
        print(f"❌ Missing file list: {F_FILE}")
        sys.exit(1)

    # Clean/create work library in target dir
    worklib_path = os.path.join(TARGET_DIR, "work")
    if os.path.exists(worklib_path):
        shutil.rmtree(worklib_path)
    os.makedirs(worklib_path, exist_ok=True)

    # Compile with vlog, using the file list and disable optimization for full debug visibility
    compile_cmd = [
        "vlog",
        "-O0",  # Disable optimization for debug
        "-work", worklib_path,
        "-f", F_FILE
    ]

    print("Compile command:", " ".join(compile_cmd))
    try:
        subprocess.run(compile_cmd, check=True)
        print("✅ Compilation successful")
    except subprocess.CalledProcessError:
        print("❌ Compilation failed")
        sys.exit(1)

# === STEP 4: Run simulation with QuestaSim vsim ===
def run_sim():
    print("\n🚀 Running simulation...")
    vcd_path = os.path.join(TARGET_DIR, VCD_FILE)
    prev_vcd_path = vcd_path.replace(".vcd", "_prev.vcd")

    # Ensure TARGET_DIR exists before simulation (fix for VCD error)
    if not os.path.exists(TARGET_DIR):
        os.makedirs(TARGET_DIR, exist_ok=True)

    # Ensure VCD output directory exists if needed (for nested paths)
    vcd_dir = os.path.dirname(vcd_path)
    if vcd_dir and not os.path.exists(vcd_dir):
        os.makedirs(vcd_dir, exist_ok=True)

    if os.path.exists(vcd_path):
        os.rename(vcd_path, prev_vcd_path)
        print(f"📦 Backed up previous VCD to: {prev_vcd_path}")

    # Guess top module name (by convention)
    top_module = f"{project}_tb"
    worklib_path = os.path.join(TARGET_DIR, "work")

    # QuestaSim expects the work library to be in the current directory or specified by -L
    # Change to target dir for simulation
    sim_cmd = [
        "vsim",
        "-c",
        "-lib", worklib_path,
        top_module,
        "-do", "run -all; quit"
    ]

    print("Simulation command:", " ".join(sim_cmd))
    try:
        subprocess.run(sim_cmd, cwd=TARGET_DIR, check=True)
        print("✅ Simulation completed")
    except subprocess.CalledProcessError:
        print("❌ Simulation failed")
        sys.exit(1)

    # After simulation:
    dump_vcd = os.path.join(TARGET_DIR, "dump.vcd")
    if os.path.exists(dump_vcd) and not os.path.exists(vcd_path):
        os.rename(dump_vcd, vcd_path)

# === STEP 5: Launch GTKWave ===
def run_gui():
    print("\n🖥️ Launching QuestaSim GUI...")
    top_module = f"{project}_tb"
    worklib_path = os.path.join(TARGET_DIR, "work")
    do_file = os.path.join(TARGET_DIR, "wave.do")

    # Create a wave.do file to add signals, open the viewer, THEN run the sim
    with open(do_filegg, "w") as f:
        f.write(f"""
# Add all signals in the testbench and DUT to the waveform viewer
add wave -r {top_module}/*
add wave -r {top_module}/dut/*

view wave

# Suppress finish prompt
set PrefMain(finishPrompt) false

# Now run the simulation until finish
run -all

# Zoom to full waveform
wave zoom full
""")

    sim_cmd = [
        "vsim",
        "-voptargs=+acc",  # Preserve all hierarchy and signal visibility
        "-lib", worklib_path,
        top_module,
        "-do", "wave.do"
    ]

    print("GUI command:", " ".join(sim_cmd))
    subprocess.run(sim_cmd, cwd=TARGET_DIR)

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
        print("Use -hw, -sim, -gui, or -all to run a build step")

if __name__ == "__main__":
    main()