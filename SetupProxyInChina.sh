#!/bin/bash

# 安装proxychains4
sudo apt update -y
sudo apt install proxychains4 -y

# 备份原始配置文件
sudo cp /etc/proxychains4.conf /etc/proxychains4.conf.bak

# 创建新的配置文件
echo 'strict_chain
proxy_dns 
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
socks5 127.0.0.1 9909' | sudo tee /etc/proxychains4.conf > /dev/null

echo "Proxy Setting Success!"
