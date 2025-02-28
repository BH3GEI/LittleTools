#!/bin/bash

# 获取当前用户的主目录绝对路径
HOME_DIR=$(eval echo ~$USER)

# 创建更新后的服务文件
cat > ~/.config/systemd/user/jupyter-notebook.service << EOF
[Unit]
Description=Jupyter Notebook

[Service]
Type=simple
ExecStart=/bin/bash -c 'source $HOME_DIR/python_envs/main_env/bin/activate && jupyter notebook --no-browser --port=9966 --ip=0.0.0.0 --NotebookApp.token="" --NotebookApp.password=""'
WorkingDirectory=$HOME_DIR
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

# 重新加载服务配置
systemctl --user daemon-reload

# 启动服务
systemctl --user start jupyter-notebook.service

# 检查服务状态
sleep 3
systemctl --user status jupyter-notebook.service
