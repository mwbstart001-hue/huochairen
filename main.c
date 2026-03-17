#include <stdio.h>
#include <string.h>

#define MAXL 105
#define MAXM 3005

const int cost[] = {6, 2, 5, 5, 4, 5, 6, 3, 7, 6};
// f[l][rem]：拼出长度为 l 且余数为 rem 的数字所需的最小火柴数
int f[MAXL][MAXM];
int p10[MAXL];

void solve() {
  int n, m;
  if (scanf("%d %d", &n, &m) != 2)
    return;

  // 预计算 10^k % m
  p10[0] = 1 % m;
  for (int i = 1; i < MAXL; i++)
    p10[i] = (p10[i - 1] * 10) % m;

  // 初始化 DP
  for (int i = 0; i <= 100; i++) {
    for (int j = 0; j < m; j++) {
      f[i][j] = 101;
    }
  }
  f[0][0] = 0;

  // DP 填表：从低位往高位推
  // f[l][rem] 表示最后 l 位的数值 V_suffix 满足 V_suffix % m == rem
  // 所需最少火柴
  for (int l = 0; l < 100; l++) {
    for (int rem = 0; rem < m; rem++) {
      if (f[l][rem] > n)
        continue;
      for (int d = 0; d <= 9; d++) {
        // 新数字是 d * 10^l + 之前的低位数字
        int next_rem = (d * p10[l] + rem) % m;
        if (f[l][rem] + cost[d] < f[l + 1][next_rem]) {
          f[l + 1][next_rem] = f[l][rem] + cost[d];
        }
      }
    }
  }

  // 寻找最大的有效长度 max_l
  int max_l = 0;
  for (int l = 100; l >= 1; l--) {
    // 必须首位不为 0 (除非题目允许，但通常正整数首位不为 0)
    for (int d = 1; d <= 9; d++) {
      int rem_needed = (m - (d * p10[l - 1]) % m) % m;
      if (f[l - 1][rem_needed] + cost[d] <= n) {
        max_l = l;
        break;
      }
    }
    if (max_l)
      break;
  }

  if (max_l == 0) {
    printf("-1\n");
    return;
  }

  // 贪心回溯构造最大数字 (从高位到低位)
  int cur_n = n;
  int target_rem = 0;
  for (int l = max_l; l >= 1; l--) {
    for (int d = 9; d >= 0; d--) {
      if (l == max_l && d == 0)
        continue;
      if (cur_n < cost[d])
        continue;

      // (d * 10^(l-1) + suffix_rem) % m == target_rem
      int suffix_rem = (target_rem - (d * p10[l - 1]) % m + m) % m;
      if (f[l - 1][suffix_rem] <= cur_n - cost[d]) {
        printf("%d", d);
        cur_n -= cost[d];
        target_rem = suffix_rem;
        break;
      }
    }
  }
  printf("\n");
}

int main() {
  int t;
  if (scanf("%d", &t) != 1)
    return 0;
  while (t--) {
    solve();
  }
  return 0;
}
