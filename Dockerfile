FROM alpine:latest

# 安装bash，因为脚本使用bash特性
RUN apk add --no-cache bash

# 设置工作目录
WORKDIR /app

# 复制脚本到容器中
COPY matchstick_number.sh /app/

# 赋予执行权限
RUN chmod +x /app/matchstick_number.sh

# 设置入口点，支持从标准输入读取数据
ENTRYPOINT ["/app/matchstick_number.sh"]
