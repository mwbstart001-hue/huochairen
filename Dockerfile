FROM alpine:latest

# 安装构建工具
RUN apk add --no-cache gcc musl-dev make bash

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 编译项目
RUN make

# 默认运行测试
CMD ["bash", "test.sh"]
