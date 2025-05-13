#!/usr/bin/env python3
import subprocess
import os
import sys
import yaml

def main():
    # Read the workflow file
    workflow_file = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), '.github', 'workflows', 'build.yml')
    
    print(f"Reading workflow from: {workflow_file}")
    try:
        with open(workflow_file, 'r') as f:
            workflow = yaml.safe_load(f)
    except Exception as e:
        print(f"Error reading workflow file: {e}")
        sys.exit(1)
    
    # Extract the build steps
    try:
        build_steps = [step for step in workflow['jobs']['build']['steps'] 
                      if 'run' in step and 'python' in step['run']]
    except KeyError:
        print("Error: Could not find build steps in workflow file")
        sys.exit(1)
    
    # Track results
    passed = []
    failed = []
    
    print("\n=== Running build steps from workflow ===\n")
    
    # Run each build step
    for step in build_steps:
        step_name = step.get('name', 'Unnamed step')
        command = step['run']
        
        print(f"\nRunning: {step_name}")
        print(f"Command: {command}")
        
        # Run the command
        process = subprocess.run(command, shell=True)
        
        if process.returncode == 0:
            status = "✅ PASSED"
            passed.append(step_name)
        else:
            status = "❌ FAILED"
            failed.append(step_name)
        
        print(f"Status: {status}")
    
    # Print summary
    print("\n=== Build Summary ===")
    print(f"Total steps: {len(build_steps)}")
    print(f"Passed: {len(passed)} - {', '.join(passed) if passed else 'None'}")
    print(f"Failed: {len(failed)} - {', '.join(failed) if failed else 'None'}")
    
    return 0 if not failed else 1

if __name__ == "__main__":
    sys.exit(main()) 