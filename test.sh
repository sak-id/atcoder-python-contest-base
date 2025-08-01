#!/bin/bash

# AtCoder sample test runner with parallel execution

test_problem() {
    local problem=$1
    local dir="${problem}"
    local code_file="${dir}/code_${problem}.py"
    local sample_file="${dir}/sample_${problem}.txt"
    
    if [[ ! -f "$code_file" ]]; then
        echo "[$problem] ERROR: $code_file not found"
        return 1
    fi
    
    if [[ ! -f "$sample_file" ]]; then
        echo "[$problem] ERROR: $sample_file not found"
        return 1
    fi
    
    # Parse JSON and run tests
    local test_count=$(python3 -c "import json; data=json.load(open('$sample_file')); print(len(data['samples']))")
    local passed=0
    local failed=0
    
    echo "[$problem] Running $test_count test cases..."
    
    for ((i=0; i<test_count; i++)); do
        local input=$(python3 -c "import json; data=json.load(open('$sample_file')); print(data['samples'][$i]['input'])")
        local expected=$(python3 -c "import json; data=json.load(open('$sample_file')); print(data['samples'][$i]['expected'])")
        
        local output=$(echo -e "$input" | python3 "$code_file" 2>/dev/null)
        
        if [[ "$output" == "$expected" ]]; then
            echo "[$problem] Test $((i+1)): AC"
            ((passed++))
        else
            echo "[$problem] Test $((i+1)): WA"
            echo "[$problem]   Expected: $expected"
            echo "[$problem]   Got:      $output"
            ((failed++))
        fi
    done
    
    echo "[$problem] Result: $passed/$test_count passed"
    return $failed
}

# Main execution
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <problem1> [problem2] ..."
    echo "Example: $0 a"
    echo "Example: $0 a b c"
    exit 1
fi

# Run tests in parallel
pids=()
for problem in "$@"; do
    test_problem "$problem" &
    pids+=($!)
done

# Wait for all tests to complete
exit_code=0
for pid in "${pids[@]}"; do
    wait $pid
    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi
done

exit $exit_code