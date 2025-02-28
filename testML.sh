#!/bin/bash

# Print colored output for better readability
print_section() {
    echo -e "\n\033[1;34m==== $1 ====\033[0m"
}

print_section "检查 Jupyter 服务状态"
systemctl --user status jupyter-notebook.service
echo "服务状态码: $?"

print_section "检查端口占用情况"
echo "检查端口 9966 是否被占用:"
netstat -tuln | grep 9966

print_section "检查 Jupyter 进程"
ps aux | grep jupyter

print_section "检查 Jupyter 配置"
mkdir -p ~/.jupyter
jupyter notebook --generate-config
echo "检查配置文件:"
cat ~/.jupyter/jupyter_notebook_config.py | grep -E "c.NotebookApp.(ip|port|allow_origin)"

print_section "重新启动 Jupyter 服务"
echo "停止现有服务..."
systemctl --user stop jupyter-notebook.service

echo "创建更新后的 Jupyter 服务配置..."
cat > ~/.config/systemd/user/jupyter-notebook.service << EOF
[Unit]
Description=Jupyter Notebook

[Service]
Type=simple
ExecStart=/bin/bash -c 'source ~/python_envs/main_env/bin/activate && jupyter notebook --no-browser --port=9966 --ip=0.0.0.0 --NotebookApp.token="" --NotebookApp.password=""'
WorkingDirectory=~/
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

echo "重新加载服务配置..."
systemctl --user daemon-reload
echo "启动服务..."
systemctl --user start jupyter-notebook.service
echo "等待服务启动..."
sleep 5
echo "检查服务状态..."
systemctl --user status jupyter-notebook.service

print_section "手动启动 Jupyter 测试"
echo "创建手动启动脚本..."
cat > ~/manual_jupyter.sh << EOF
#!/bin/bash
source ~/python_envs/main_env/bin/activate
jupyter notebook --no-browser --port=9966 --ip=0.0.0.0 --NotebookApp.token="" --NotebookApp.password=""
EOF
chmod +x ~/manual_jupyter.sh

print_section "验证连接"
echo "尝试连接到 Jupyter 服务:"
curl -v http://localhost:9966

print_section "提示和建议"
echo -e "\033[1;33m如果上述调试没有解决问题，请尝试以下操作:\033[0m"
echo "1. 手动运行 Jupyter:"
echo "    ~/manual_jupyter.sh"
echo "2. 检查防火墙设置:"
echo "    sudo firewall-cmd --list-all"
echo "3. 检查 Python 环境:"
echo "    source ~/python_envs/main_env/bin/activate && pip list | grep jupyter"
echo "4. 检查日志文件:"
echo "    journalctl --user -u jupyter-notebook.service -n 50"
echo "5. 确认您的虚拟环境中已安装 Jupyter:"
echo "    source ~/python_envs/main_env/bin/activate && pip install notebook"
echo "6. 尝试使用不同端口:"
echo "    编辑服务文件并使用另一个端口，如 8888 或 8080"

print_section "完成"
echo -e "\033[1;32m调试脚本执行完毕。请根据上述输出分析问题。\033[0m"
