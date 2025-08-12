#!/bin/bash

# AtCoder sample test runner with parallel execution and nth result display

show_nth_result() {
    local problem=$1
    local test_num=$2
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
    
    # Parse JSON and get test count
    local test_count=$(python3 -c "import json; data=json.load(open('$sample_file')); print(len(data['samples']))")
    
    if [[ $test_num -lt 1 || $test_num -gt $test_count ]]; then
        echo "[$problem] ERROR: Test number $test_num is out of range (1-$test_count)"
        return 1
    fi
    
    # Get the specific test case (convert to 0-based index)
    local i=$((test_num - 1))
    local input=$(python3 -c "import json; data=json.load(open('$sample_file')); print(data['samples'][$i]['input'])")
    local expected=$(python3 -c "import json; data=json.load(open('$sample_file')); print(data['samples'][$i]['expected'])")
    
    echo "[$problem] Running test case $test_num..."
    echo "[$problem] Input:"
    echo "$input"
    echo "[$problem] Expected output:"
    echo "$expected"
    
    # Run the code and capture both stdout and stderr
    local output
    local error_output
    local exit_code
    
    output=$(echo -e "$input" | python3 "$code_file" 2>&1)
    exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        echo "[$problem] Runtime Error:"
        echo "$output"
        return 1
    fi
    
    echo "[$problem] Actual output:"
    echo "$output"
    
    if [[ "$output" == "$expected" ]]; then
        echo "[$problem] Result: AC"
        return 0
    else
        echo "[$problem] Result: WA"
        return 1
    fi
}

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
    echo "       $0 <problem> <test_number>"
    echo "Example: $0 a"
    echo "Example: $0 a b c"
    echo "Example: $0 b 2        # Show detailed result of test case 2 for problem b"
    exit 1
fi

# Check if this is a single problem with test number
if [[ $# -eq 2 && $2 =~ ^[0-9]+$ ]]; then
    show_nth_result "$1" "$2"
    exit $?
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