#!/bin/bash

# Print colored output for better readability
print_section() {
    echo -e "\n\033[1;34m==== $1 ====\033[0m"
}

# Function to check if command executed successfully
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32m✓ Success: $1\033[0m"
    else
        echo -e "\033[1;31m✗ Error: $1\033[0m"
        echo "You may need to run this script again or fix the issue manually."
    fi
}

print_section "Updating system packages"
sudo apt update && sudo apt upgrade -y
check_status "System update"

print_section "Installing essential packages"
sudo apt install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    htop \
    zip \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates
check_status "Essential packages installation"

print_section "Setting up NVIDIA GPU for WSL2"
# Install NVIDIA drivers for WSL2
sudo apt install -y nvidia-driver-535-server
check_status "NVIDIA driver installation"

# Install CUDA toolkit
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install -y cuda-toolkit-12-5
check_status "CUDA toolkit installation"

# Set CUDA environment variables
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
check_status "CUDA environment variables setup"

print_section "Installing Python and related tools"
sudo apt install -y python3 python3-pip python3-venv
check_status "Python installation"

# Create a Python virtual environment
mkdir -p ~/python_envs
python3 -m venv ~/python_envs/main_env
source ~/python_envs/main_env/bin/activate
check_status "Python virtual environment creation"

print_section "Installing common Python libraries"
pip install --upgrade pip
pip install \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn \
    tensorflow \
    torch torchvision torchaudio \
    jupyter \
    jupyterlab \
    notebook
check_status "Python libraries installation"

print_section "Setting up automatic Jupyter Notebook launch"
# Create a systemd service file for the current user
mkdir -p ~/.config/systemd/user/
cat > ~/.config/systemd/user/jupyter-notebook.service << EOF
[Unit]
Description=Jupyter Notebook

[Service]
Type=simple
ExecStart=/bin/bash -c 'source ~/python_envs/main_env/bin/activate && jupyter notebook --no-browser --port=9966 --ip=0.0.0.0'
WorkingDirectory=~/
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

# Enable the service
systemctl --user daemon-reload
systemctl --user enable jupyter-notebook.service
check_status "Jupyter Notebook service setup"

# Add jupyter notebook to PATH
echo 'export PATH=$PATH:~/python_envs/main_env/bin' >> ~/.bashrc

print_section "Creating script to start Jupyter"
# Create a simple script to start Jupyter manually if needed
cat > ~/start_jupyter.sh << EOF
#!/bin/bash
source ~/python_envs/main_env/bin/activate
jupyter notebook --no-browser --port=9966 --ip=0.0.0.0
EOF
chmod +x ~/start_jupyter.sh
check_status "Jupyter start script creation"

# Test NVIDIA setup
print_section "Testing NVIDIA GPU setup"
source ~/.bashrc
nvidia-smi
check_status "NVIDIA GPU detection"

print_section "Setup completed!"
echo -e "\033[1;32m"
echo "Your WSL2 Ubuntu 24 environment has been configured with:"
echo "✓ Essential Linux packages"
echo "✓ NVIDIA 3060 GPU support"
echo "✓ Common Python libraries"
echo "✓ Jupyter Notebook auto-start on port 9966"
echo -e "\033[0m"
echo -e "\033[1;33mNotes:\033[0m"
echo "1. Restart your WSL session for all changes to take effect: 'wsl --shutdown' from Windows PowerShell"
echo "2. After restart, Jupyter should start automatically"
echo "3. Access Jupyter at: http://localhost:9966"
echo "4. The token will be displayed in the console when Jupyter starts"
echo "5. If Jupyter doesn't start, run '~/start_jupyter.sh' manually"
echo "6. To activate the Python environment manually: 'source ~/python_envs/main_env/bin/activate'"
