#!/bin/bash

matchstick_solver() {
    local n=$1
    local m=$2
    
    if [ "$n" -lt 2 ]; then
        echo "-1"
        return
    fi
    
    awk -v n="$n" -v m="$m" '
    BEGIN {
        cost[0] = 6
        cost[1] = 2
        cost[2] = 5
        cost[3] = 5
        cost[4] = 4
        cost[5] = 5
        cost[6] = 6
        cost[7] = 3
        cost[8] = 7
        cost[9] = 6
        
        for (i = 0; i <= n; i++) {
            for (j = 0; j < m; j++) {
                dp[i, j] = ""
            }
        }
        
        for (d = 1; d <= 9; d++) {
            c = cost[d]
            if (c <= n) {
                rem = d % m
                if (dp[c, rem] == "" || length(dp[c, rem]) < 1) {
                    dp[c, rem] = sprintf("%d", d)
                }
            }
        }
        
        for (i = 2; i <= n; i++) {
            for (j = 0; j < m; j++) {
                if (dp[i, j] != "") {
                    for (d = 0; d <= 9; d++) {
                        c = cost[d]
                        new_i = i + c
                        if (new_i <= n) {
                            new_j = (j * 10 + d) % m
                            candidate = dp[i, j] sprintf("%d", d)
                            current = dp[new_i, new_j]
                            
                            if (current == "") {
                                dp[new_i, new_j] = candidate
                            } else {
                                len_current = length(current)
                                len_candidate = length(candidate)
                                
                                if (len_candidate > len_current) {
                                    dp[new_i, new_j] = candidate
                                } else if (len_candidate == len_current) {
                                    if (candidate > current) {
                                        dp[new_i, new_j] = candidate
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        result = ""
        for (i = 2; i <= n; i++) {
            candidate = dp[i, 0]
            if (candidate != "") {
                if (result == "") {
                    result = candidate
                } else {
                    len_result = length(result)
                    len_candidate = length(candidate)
                    
                    if (len_candidate > len_result) {
                        result = candidate
                    } else if (len_candidate == len_result) {
                        if (candidate > result) {
                            result = candidate
                        }
                    }
                }
            }
        }
        
        if (result != "") {
            print result
        } else {
            print "-1"
        }
    }'
}

main() {
    local T
    read -r T
    
    if ! [[ "$T" =~ ^[0-9]+$ ]] || [ "$T" -le 0 ]; then
        echo "-1"
        return 1
    fi
    
    for ((t=1; t<=T; t++)); do
        local line
        read -r line
        
        local n m
        read -r n m <<< "$line"
        
        if ! [[ "$n" =~ ^[0-9]+$ ]] || ! [[ "$m" =~ ^[0-9]+$ ]]; then
            echo "-1"
            continue
        fi
        
        if [ "$m" -eq 0 ]; then
            echo "-1"
            continue
        fi
        
        matchstick_solver "$n" "$m"
    done
}

main
