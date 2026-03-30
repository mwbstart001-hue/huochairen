#!/bin/bash

# 火柴数问题求解器
# 使用动态规划求解最大可被m整除的数字

# 数字对应的火柴消耗数量: 0-9
cost=(6 2 5 5 4 5 6 3 7 6)

# 主函数
main() {
    read T
    for ((t=0; t<T; t++)); do
        read n m
        solve "$n" "$m"
    done
}

# 解决单个测试用例
solve() {
    local n=$1
    local m=$2
    
    # 边界校验：火柴数小于2时直接输出-1
    if (( n < 2 )); then
        echo -1
        return
    fi
    
    # 特殊情况：m=1时直接返回最大数
    if (( m == 1 )); then
        max_num_for_m1 "$n"
        return
    fi
    
    # 使用动态规划求解
    dp_solve "$n" "$m"
}

# m=1时的特殊处理
max_num_for_m1() {
    local n=$1
    local max_len=$((n / 2))
    local rem=$((n % 2))
    
    if (( rem == 1 && max_len > 0 )); then
        printf "7"
        for ((i=1; i<max_len; i++)); do
            printf "1"
        done
    else
        for ((i=0; i<max_len; i++)); do
            printf "1"
        done
    fi
    printf "\n"
}

# 动态规划求解
dp_solve() {
    local n=$1
    local m=$2
    
    # dp[i][j] = 用i根火柴得到余数j的最大数字长度
    # best_digit[i][j] = 达到该状态的最后一个数字
    # prev_i[i][j], prev_j[i][j] = 前驱状态
    declare -a dp
    declare -a best_digit
    declare -a prev_i
    declare -a prev_j
    
    # 初始化
    for ((i=0; i<=n; i++)); do
        for ((j=0; j<m; j++)); do
            idx=$((i * m + j))
            dp[$idx]=-1
            best_digit[$idx]=-1
            prev_i[$idx]=-1
            prev_j[$idx]=-1
        done
    done
    
    # 初始状态：0根火柴，余数0，长度0
    dp[0]=0
    
    # 填充DP表
    for ((i=0; i<=n; i++)); do
        for ((j=0; j<m; j++)); do
            idx=$((i * m + j))
            if (( dp[$idx] == -1 )); then
                continue
            fi
            
            # 尝试添加每个数字
            for ((d=0; d<=9; d++)); do
                # 跳过前导0
                if (( i == 0 && d == 0 )); then
                    continue
                fi
                
                c=${cost[$d]}
                new_i=$((i + c))
                if (( new_i > n )); then
                    continue
                fi
                
                new_j=$(((j * 10 + d) % m))
                new_idx=$((new_i * m + new_j))
                new_len=$((dp[$idx] + 1))
                
                # 更新DP状态：优先长度更长
                if (( new_len > dp[$new_idx] )); then
                    dp[$new_idx]=$new_len
                    best_digit[$new_idx]=$d
                    prev_i[$new_idx]=$i
                    prev_j[$new_idx]=$j
                fi
            done
        done
    done
    
    # 寻找最优解：长度最长，长度相同则使用火柴更少
    local max_len=-1
    local best_i=-1
    
    for ((i=0; i<=n; i++)); do
        idx=$((i * m + 0))  # 余数为0
        if (( dp[$idx] > max_len )); then
            max_len=${dp[$idx]}
            best_i=$i
        elif (( dp[$idx] == max_len && i < best_i )); then
            best_i=$i
        fi
    done
    
    if (( max_len <= 0 )); then
        echo -1
        return
    fi
    
    # 回溯构建数字
    local result=""
    local current_i=$best_i
    local current_j=0
    
    while (( current_i > 0 )); do
        idx=$((current_i * m + current_j))
        d=${best_digit[$idx]}
        
        if (( d == -1 )); then
            break
        fi
        
        result="$d$result"
        
        # 回溯到前一个状态
        pi=${prev_i[$idx]}
        pj=${prev_j[$idx]}
        
        if (( pi == -1 )); then
            break
        fi
        
        current_i=$pi
        current_j=$pj
    done
    
    # 检查前导0
    if [[ ${#result} -gt 1 && ${result:0:1} == "0" ]]; then
        echo -1
        return
    fi
    
    echo "$result"
}

# 运行主程序
main
