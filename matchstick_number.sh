#!/bin/bash

# 火柴数字问题 - 使用不超过n根火柴摆出能被m整除的最大正整数
# 数字火柴消耗: 0→6, 1→2, 2→5, 3→5, 4→4, 5→5, 6→6, 7→3, 8→7, 9→6

# 数字到火柴数的映射（使用字符串模拟）
# 0=6, 1=2, 2=5, 3=5, 4=4, 5=5, 6=6, 7=3, 8=7, 9=6
get_digit_cost() {
    local digit=$1
    case $digit in
        0|6|9) echo 6 ;;
        1) echo 2 ;;
        2|3|5) echo 5 ;;
        4) echo 4 ;;
        7) echo 3 ;;
        8) echo 7 ;;
    esac
}

# 按数字大小排序（用于同位数时选大数字）
digits_desc="9 8 7 6 5 4 3 2 1 0"

# 求解单个测试用例
solve() {
    local n=$1
    local m=$2

    # 约束1: 边界兜底校验，火柴数n < 2时直接输出-1
    if [[ $n -lt 2 ]]; then
        echo "-1"
        return
    fi

    # 特殊情况：m=1时，任何数都能被1整除，只需最大化数字
    if [[ $m -eq 1 ]]; then
        build_max_number $n
        return
    fi

    # 使用BFS/DP求解
    # 由于macOS bash不支持关联数组，使用临时文件存储DP状态
    # 格式: sticks,mod=value

    local tmpdir=$(mktemp -d)
    local dp_file="$tmpdir/dp"
    touch "$dp_file"

    # 初始化: 0根火柴，余数0，空字符串
    echo "0,0=" >> "$dp_file"

    # 按火柴数从小到大填充DP表
    for ((sticks=0; sticks<=n; sticks++)); do
        for ((mod=0; mod<m; mod++)); do
            # 读取当前状态
            local current=$(grep "^$sticks,$mod=" "$dp_file" 2>/dev/null | tail -1 | cut -d'=' -f2)

            if [[ -z "$current" && $sticks -ne 0 ]]; then
                continue
            fi
            if [[ $sticks -eq 0 && $mod -ne 0 ]]; then
                continue
            fi

            # 尝试在每个位置添加新数字
            for digit in $digits_desc; do
                local cost=$(get_digit_cost $digit)
                local new_sticks=$((sticks + cost))

                if [[ $new_sticks -gt $n ]]; then
                    continue
                fi

                # 计算新的余数
                local new_mod=$(( (mod * 10 + digit) % m ))
                local new_val="${current}${digit}"

                # 约束2: 禁止以0开头（除非数字本身就是0）
                if [[ -z "$current" && "$digit" == "0" ]]; then
                    # 单独检查0是否合法
                    if [[ $new_sticks -le $n && $((digit % m)) -eq 0 ]]; then
                        local existing=$(grep "^$new_sticks,0=" "$dp_file" 2>/dev/null | tail -1 | cut -d'=' -f2)
                        local should_update=false

                        if [[ -z "$existing" ]]; then
                            should_update=true
                        else
                            local new_len=${#new_val}
                            local exist_len=${#existing}
                            if [[ $new_len -gt $exist_len ]]; then
                                should_update=true
                            elif [[ $new_len -eq $exist_len && "$new_val" > "$existing" ]]; then
                                should_update=true
                            fi
                        fi

                        if [[ "$should_update" == "true" ]]; then
                            # 删除旧记录，添加新记录
                            grep -v "^$new_sticks,0=" "$dp_file" > "$dp_file.tmp" 2>/dev/null || true
                            mv "$dp_file.tmp" "$dp_file"
                            echo "$new_sticks,0=$new_val" >> "$dp_file"
                        fi
                    fi
                    continue
                fi

                # 更新DP
                local existing=$(grep "^$new_sticks,$new_mod=" "$dp_file" 2>/dev/null | tail -1 | cut -d'=' -f2)
                local should_update=false

                if [[ -z "$existing" ]]; then
                    should_update=true
                else
                    local new_len=${#new_val}
                    local exist_len=${#existing}
                    if [[ $new_len -gt $exist_len ]]; then
                        should_update=true
                    elif [[ $new_len -eq $exist_len && "$new_val" > "$existing" ]]; then
                        should_update=true
                    fi
                fi

                if [[ "$should_update" == "true" ]]; then
                    grep -v "^$new_sticks,$new_mod=" "$dp_file" > "$dp_file.tmp" 2>/dev/null || true
                    mv "$dp_file.tmp" "$dp_file"
                    echo "$new_sticks,$new_mod=$new_val" >> "$dp_file"
                fi
            done
        done
    done

    # 在所有使用不超过n根火柴且余数为0的状态中找最大值
    local best=""
    for ((sticks=1; sticks<=n; sticks++)); do
        local candidate=$(grep "^$sticks,0=" "$dp_file" 2>/dev/null | tail -1 | cut -d'=' -f2)
        if [[ -n "$candidate" ]]; then
            # 去除前导零
            candidate=$(echo "$candidate" | sed 's/^0*//')
            if [[ -z "$candidate" ]]; then
                candidate="0"
            fi

            if [[ -z "$best" ]]; then
                best="$candidate"
            else
                local cand_len=${#candidate}
                local best_len=${#best}
                if [[ $cand_len -gt $best_len ]]; then
                    best="$candidate"
                elif [[ $cand_len -eq $best_len && "$candidate" > "$best" ]]; then
                    best="$candidate"
                fi
            fi
        fi
    done

    # 清理临时文件
    rm -rf "$tmpdir"

    if [[ -z "$best" ]]; then
        echo "-1"
    else
        echo "$best"
    fi
}

# 当m=1时，构建最大数字（只需最大化位数和数值）
build_max_number() {
    local n=$1
    local result=""

    # 贪心策略：优先使用消耗少的数字来增加位数
    # 但为了数字最大，在位数确定后，高位应尽量大

    # 第一步：计算最大位数
    local max_digits=0
    local temp_n=$n
    while [[ $temp_n -ge 2 ]]; do
        ((max_digits++))
        ((temp_n -= 2))
    done

    if [[ $max_digits -eq 0 ]]; then
        echo "-1"
        return
    fi

    # 第二步：构建最大数字
    # 从高位到低位，尽量放大的数字
    local remaining=$n
    for ((i=0; i<max_digits; i++)); do
        # 后面还需要 (max_digits - i - 1) 个数字，每个至少消耗2根火柴
        local remaining_positions=$((max_digits - i - 1))
        local min_needed_for_rest=$((remaining_positions * 2))

        # 尝试从大到小放数字
        local placed=false
        for digit in $digits_desc; do
            # 约束2: 首位不能是0
            if [[ $i -eq 0 && "$digit" == "0" ]]; then
                continue
            fi

            local cost=$(get_digit_cost $digit)
            local after_place=$((remaining - cost))

            # 检查放置后是否还有足够的火柴给后面的位
            if [[ $after_place -ge $min_needed_for_rest ]]; then
                result="${result}${digit}"
                remaining=$after_place
                placed=true
                break
            fi
        done

        if [[ "$placed" == "false" ]]; then
            # 无法放置，尝试用最小消耗的数字填充
            if [[ $remaining -ge 2 ]]; then
                result="${result}1"
                ((remaining -= 2))
            fi
        fi
    done

    if [[ -z "$result" ]]; then
        echo "-1"
    else
        echo "$result"
    fi
}

# 主函数
main() {
    # 约束5: 程序执行流程 - 读取输入
    local T
    read -r T

    # 检查T是否为正整数
    if ! [[ "$T" =~ ^[0-9]+$ ]] || [[ "$T" -lt 1 ]]; then
        echo "Error: 第一行必须是正整数T" >&2
        exit 1
    fi

    local results=()

    # 逐组处理
    for ((i=0; i<T; i++)); do
        local line
        read -r line

        # 解析n和m
        local n=$(echo "$line" | awk '{print $1}')
        local m=$(echo "$line" | awk '{print $2}')

        # 输入校验
        if ! [[ "$n" =~ ^[0-9]+$ ]] || ! [[ "$m" =~ ^[0-9]+$ ]]; then
            results+=("-1")
            continue
        fi

        if [[ "$m" -eq 0 ]]; then
            results+=("-1")
            continue
        fi

        # 求解并存储结果
        local result
        result=$(solve "$n" "$m")
        results+=("$result")
    done

    # 输出结果
    for result in "${results[@]}"; do
        echo "$result"
    done
}

# 运行主函数
main
