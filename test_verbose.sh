#!/bin/bash
# 测试脚本

echo "=== Testing test_cases.txt ==="
count=0
while read -r line; do
    count=$((count + 1))
    echo "Line $count: '$line'"
done < test_cases.txt

echo ""
echo "=== Running solver with strace ==="
cat test_cases.txt | timeout 10 ./matchstick_solver.sh
echo "Exit code: $?"
