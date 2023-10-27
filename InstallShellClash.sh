#!/bin/bash

# 安装必要的依赖
sudo apt update -y
sudo apt install wget curl unzip -y

# 下载并运行ShellClash的安装脚本
bash <(curl -Ls https://raw.githubusercontent.com/juewuy/ShellClash/master/install.sh)
