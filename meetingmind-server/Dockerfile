# 使用官方 Python 3.10 镜像作为基础镜像
FROM python:3.10-slim
# 设置环境变量，防止 Python 生成 .pyc 文件和输出缓冲
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
# 设置时区为上海
ENV TZ=Asia/Shanghai
# 设置工作目录为 /app
ENV LANG C.UTF-8

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends libopus\
    && apt-get install -y --no-install-recommends ffmpeg\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制项目文件到容器中
COPY . .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 暴露 WebSocket 服务端口
EXPOSE 8000

# 设置容器启动命令
CMD ["python", "app.py"]