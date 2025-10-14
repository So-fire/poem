#!/bin/bash

# Bifrost Installation Script for WSL Ubuntu
# This script installs OpenStack Bifrost on WSL Ubuntu
# Reference: https://docs.openstack.org/bifrost/latest/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Bifrost Installation for WSL Ubuntu${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on WSL
print_status "Checking if running on WSL..."
if ! grep -qi microsoft /proc/version; then
    print_warning "This doesn't appear to be WSL. Continuing anyway..."
fi

# Check Ubuntu version
print_status "Checking Ubuntu version..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Detected: $PRETTY_NAME"
else
    print_error "Cannot determine OS version"
    exit 1
fi

# Update system packages
print_status "Updating system packages..."
sudo apt-get update

# Install required dependencies
print_status "Installing required dependencies..."
sudo apt-get install -y \
    git \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    libssl-dev \
    libffi-dev \
    build-essential \
    libpq-dev \
    libvirt-dev \
    pkg-config \
    bridge-utils \
    debootstrap \
    ifenslave \
    ifenslave-2.6 \
    lsof \
    lvm2 \
    openssh-server \
    libvirt-daemon-system \
    libvirt-clients \
    qemu-kvm \
    qemu-utils \
    curl \
    jq

# Install Ansible
print_status "Installing Ansible..."
sudo apt-get install -y ansible

# Create bifrost directory
BIFROST_DIR="$HOME/bifrost"
print_status "Creating Bifrost directory at $BIFROST_DIR..."
mkdir -p "$BIFROST_DIR"
cd "$BIFROST_DIR"

# Clone Bifrost repository
if [ ! -d "$BIFROST_DIR/bifrost" ]; then
    print_status "Cloning Bifrost repository..."
    git clone https://opendev.org/openstack/bifrost.git
else
    print_status "Bifrost repository already exists, pulling latest changes..."
    cd bifrost
    git pull
    cd ..
fi

cd "$BIFROST_DIR/bifrost"

# Create Python virtual environment
print_status "Creating Python virtual environment..."
python3 -m venv "$BIFROST_DIR/bifrost-venv"
source "$BIFROST_DIR/bifrost-venv/bin/activate"

# Upgrade pip and install basic requirements
print_status "Upgrading pip and installing Python dependencies..."
pip install --upgrade pip setuptools wheel

# Install Bifrost and its dependencies
print_status "Installing Bifrost..."
pip install .

# Install Ansible collections and roles
print_status "Installing Ansible collections..."
ansible-galaxy collection install -r requirements.yml || true

# Create default configuration
print_status "Creating default configuration..."
mkdir -p "$BIFROST_DIR/bifrost-config"

# Create a sample configuration file
cat > "$BIFROST_DIR/bifrost-config/bifrost.yml" << 'EOF'
---
# Bifrost Configuration
# This is a basic configuration file for Bifrost

# Network settings
network_interface: eth0
dhcp_pool_start: 192.168.1.200
dhcp_pool_end: 192.168.1.250

# Deployment settings
enable_keystone: false
noauth_mode: true
testing: false

# Image settings
deploy_image_filename: "ubuntu-20.04-server-cloudimg-amd64.img"
deploy_image: "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"

# Hardware types
enabled_hardware_types: ipmi
EOF

# Create a sample inventory file
cat > "$BIFROST_DIR/bifrost-config/inventory.yml" << 'EOF'
---
# Sample inventory file for Bifrost
# Customize this file with your actual hardware details

baremetal1:
  uuid: "00000000-0000-0000-0000-000000000001"
  driver_info:
    power:
      ipmi_address: "192.168.1.100"
      ipmi_username: "admin"
      ipmi_password: "password"
  nics:
    - mac: "00:11:22:33:44:55"
  properties:
    cpu_arch: "x86_64"
    ram: "8192"
    disk_size: "100"
    cpus: "4"
EOF

# Create installation summary
cat > "$BIFROST_DIR/INSTALLATION_INFO.txt" << EOF
Bifrost Installation Summary
============================

Installation Directory: $BIFROST_DIR
Virtual Environment: $BIFROST_DIR/bifrost-venv
Configuration Directory: $BIFROST_DIR/bifrost-config

To activate Bifrost environment:
    source $BIFROST_DIR/bifrost-venv/bin/activate

Configuration files:
    - Main config: $BIFROST_DIR/bifrost-config/bifrost.yml
    - Inventory: $BIFROST_DIR/bifrost-config/inventory.yml

Next Steps:
1. Customize the configuration files in $BIFROST_DIR/bifrost-config/
2. Set up your inventory with actual hardware details
3. Run the Bifrost playbooks to install and configure services

Quick Start Commands:
    cd $BIFROST_DIR/bifrost
    source $BIFROST_DIR/bifrost-venv/bin/activate
    
    # Install Bifrost services
    ansible-playbook -i inventory/target playbooks/install.yaml
    
    # Enroll nodes
    ansible-playbook -i inventory/target playbooks/enroll-dynamic.yaml

Documentation: https://docs.openstack.org/bifrost/latest/

EOF

print_status "Installation complete!"
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Summary${NC}"
echo -e "${GREEN}========================================${NC}"
cat "$BIFROST_DIR/INSTALLATION_INFO.txt"

print_status "To get started, activate the virtual environment:"
echo -e "    ${YELLOW}source $BIFROST_DIR/bifrost-venv/bin/activate${NC}"
echo ""
print_status "Configuration files created at: $BIFROST_DIR/bifrost-config/"
echo ""
print_warning "Please review and customize the configuration files before deploying!"
