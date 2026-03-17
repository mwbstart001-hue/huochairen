#!/bin/bash

# 编译程序
make

# 测试函数
run_test() {
    local input="$1"
    local expected="$2"
    local desc="$3"
    
    echo "测试 $desc: 输入 \"$input\""
    result=$(echo "$input" | ./matchstick)
    
    if [ "$result" == "$expected" ]; then
        echo "✅ 通过: 得到 $result"
    else
        echo "❌ 失败: 期望 $expected, 但得到 $result"
    fi
    echo "-----------------------------------"
}

# 测试用例 1: 样例 1
run_test "1
6 3" "111" "样例 1 (6 3)"

# 测试用例 2: 样例 2 (无解)
run_test "1
5 6" "-1" "样例 2 (5 6)"

# 测试用例 3: 整除 1 (最长优先)
run_test "1
10 1" "11111" "整除 1 (10 1)"

# 测试用例 4: 字典序最大优先
run_test "1
15 13" "717171" "余数 13 (15 13)"

# 测试用例 5: 大范围压力测试 (通过程序自测结果作为基准)
echo "测试 大压力测试 (100 3000):"
echo "1
100 3000" | ./matchstick
echo "-----------------------------------"

echo "所有测试执行完毕。"
