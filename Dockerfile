# 使用轻量级Alpine Linux作为基础镜像
FROM alpine:3.18

# 设置工作目录
WORKDIR /app

# 安装bash（Alpine默认使用ash）
RUN apk add --no-cache bash

# 复制脚本到容器中
COPY matchstick_solver.sh .

# 赋予执行权限
RUN chmod +x matchstick_solver.sh

# 设置入口点
ENTRYPOINT ["/bin/bash", "/app/matchstick_solver.sh"]
