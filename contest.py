#!/usr/bin/env python3

import os
import sys
import json
import shutil
from pathlib import Path

def create_contest_dir(contest_name):
    """Create contest directory with a-h problem subdirectories"""
    contest_path = Path(contest_name)
    
    if contest_path.exists():
        print(f"Contest directory '{contest_name}' already exists")
        return False
    
    print(f"Creating contest directory: {contest_name}")
    contest_path.mkdir()
    
    # Copy test.sh to contest directory
    if Path("test.sh").exists():
        shutil.copy2("test.sh", contest_path / "test.sh")
    
    # Create problem directories a-h
    problems = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
    template_dir = Path("template")
    
    for problem in problems:
        problem_path = contest_path / problem
        problem_path.mkdir()
        
        # Create code file
        code_template = template_dir / "code_template.py" if template_dir.exists() else Path("a/code_a.py")
        if code_template.exists():
            with open(code_template, 'r') as f:
                template_content = f.read()
            
            with open(problem_path / f"code_{problem}.py", 'w') as f:
                f.write(template_content)
        
        # Create sample file
        sample_template = template_dir / "sample_template.txt" if template_dir.exists() else None
        sample_content = {
            "problem_url": f"https://atcoder.jp/contests/{contest_name}/tasks/{contest_name}_{problem}",
            "samples": [
                {
                    "input": "",
                    "expected": ""
                }
            ]
        }
        
        with open(problem_path / f"sample_{problem}.txt", 'w') as f:
            json.dump(sample_content, f, indent=2)
    
    print(f"Created {len(problems)} problem directories: {', '.join(problems)}")
    print(f"\nNext steps:")
    print(f"1. cd {contest_name}")
    print(f"2. Edit code files and add sample test cases")
    print(f"3. Run: ./test.sh a b c")
    
    return True

def main():
    if len(sys.argv) != 2:
        print("Usage: ./contest.py <contest_name>")
        print("Example: ./contest.py abc123")
        sys.exit(1)
    
    contest_name = sys.argv[1]
    
    # Validate contest name (basic check)
    if not contest_name.isalnum():
        print("Contest name should be alphanumeric (e.g., abc123)")
        sys.exit(1)
    
    success = create_contest_dir(contest_name)
    if not success:
        sys.exit(1)

if __name__ == "__main__":
    main()