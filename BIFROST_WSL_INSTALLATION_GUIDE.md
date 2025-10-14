# Bifrost Installation Guide for Windows WSL Ubuntu

This guide will help you install OpenStack Bifrost on Windows using WSL (Windows Subsystem for Linux) with Ubuntu.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation Steps](#installation-steps)
3. [Configuration](#configuration)
4. [Running Bifrost](#running-bifrost)
5. [Troubleshooting](#troubleshooting)
6. [Next Steps](#next-steps)

## Prerequisites

### WSL Ubuntu Requirements
- Windows 10/11 with WSL2 enabled
- WSL Ubuntu 20.04 or 22.04 installed
- At least 4GB RAM allocated to WSL
- At least 20GB free disk space

### Check Your WSL Version
```bash
wsl --list --verbose
```
Ensure you're running WSL2 for better performance.

### Update WSL Ubuntu
```bash
sudo apt-get update
sudo apt-get upgrade -y
```

## What is Bifrost?

Bifrost is an OpenStack project that provides a simple way to deploy baremetal servers using Ironic. It's designed to be:
- Easy to set up and use
- Self-contained with minimal dependencies
- Suitable for development, testing, and production deployments

## Installation Steps

### Quick Installation (Automated)

1. **Download and run the installation script:**
   ```bash
   chmod +x install_bifrost_wsl.sh
   ./install_bifrost_wsl.sh
   ```

### Manual Installation

If you prefer to install manually, follow these steps:

#### 1. Install System Dependencies

```bash
sudo apt-get update
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
    ansible \
    bridge-utils \
    debootstrap \
    libvirt-daemon-system \
    libvirt-clients \
    qemu-kvm \
    qemu-utils
```

#### 2. Clone Bifrost Repository

```bash
mkdir -p ~/bifrost
cd ~/bifrost
git clone https://opendev.org/openstack/bifrost.git
cd bifrost
```

#### 3. Create Python Virtual Environment

```bash
python3 -m venv ~/bifrost/bifrost-venv
source ~/bifrost/bifrost-venv/bin/activate
```

#### 4. Install Bifrost

```bash
pip install --upgrade pip setuptools wheel
pip install .
```

#### 5. Install Ansible Dependencies

```bash
ansible-galaxy collection install -r requirements.yml
```

## Configuration

### 1. Basic Configuration

Create a configuration directory:
```bash
mkdir -p ~/bifrost/bifrost-config
```

### 2. Create Variables File

Create `~/bifrost/bifrost-config/bifrost-vars.yml`:

```yaml
---
# Network Interface Configuration
network_interface: eth0

# Authentication
enable_keystone: false
noauth_mode: true

# Testing mode (set to true for development)
testing: false

# DHCP Configuration
dhcp_pool_start: 192.168.1.200
dhcp_pool_end: 192.168.1.250
dhcp_lease_time: 12h

# Image Configuration
deploy_image_filename: "ubuntu-22.04-server-cloudimg-amd64.img"
deploy_image: "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"

# Hardware Types
enabled_hardware_types: ipmi,redfish

# Ironic Settings
ironic_debug: true
```

### 3. Create Inventory File

Create `~/bifrost/bifrost-config/inventory.yml`:

```yaml
---
# This is a sample inventory file for your baremetal nodes
# Customize with your actual hardware details

node1:
  uuid: "00000000-0000-0000-0000-000000000001"
  name: "server-01"
  driver: "ipmi"
  driver_info:
    power:
      ipmi_address: "192.168.1.100"
      ipmi_username: "admin"
      ipmi_password: "password"
      ipmi_port: 623
  nics:
    - mac: "00:11:22:33:44:55"
  properties:
    cpu_arch: "x86_64"
    ram: 16384
    disk_size: 500
    cpus: 8
  instance_info:
    image_source: "{{ deploy_image }}"
    root_gb: 50

# Add more nodes as needed
```

## Running Bifrost

### 1. Activate Virtual Environment

Always activate the virtual environment before running Bifrost:
```bash
source ~/bifrost/bifrost-venv/bin/activate
cd ~/bifrost/bifrost
```

### 2. Install Bifrost Services

```bash
# Install with default settings
ansible-playbook -i inventory/target playbooks/install.yaml

# Or install with custom variables
ansible-playbook -i inventory/target playbooks/install.yaml \
    -e @~/bifrost/bifrost-config/bifrost-vars.yml
```

### 3. Enroll Nodes

```bash
# Enroll nodes from your inventory
ansible-playbook -i inventory/baremetal playbooks/enroll-dynamic.yaml \
    -e @~/bifrost/bifrost-config/inventory.yml
```

### 4. Deploy Nodes

```bash
# Deploy enrolled nodes
ansible-playbook -i inventory/baremetal playbooks/deploy-dynamic.yaml
```

## Troubleshooting

### Common Issues

#### 1. **WSL Network Issues**

If you're having network connectivity issues:
```bash
# Check network interface
ip addr show

# Restart networking (if needed)
sudo service networking restart
```

#### 2. **Libvirt/KVM Issues in WSL**

WSL doesn't support KVM by default. For testing purposes, you can:
- Use Bifrost in "testing" mode
- Configure Bifrost to use virtual machines on your Windows host
- Use a dedicated Linux machine or VM for production deployments

To enable testing mode, add to your variables:
```yaml
testing: true
enable_venv: true
```

#### 3. **Python Dependencies Issues**

If you encounter Python package conflicts:
```bash
# Recreate the virtual environment
rm -rf ~/bifrost/bifrost-venv
python3 -m venv ~/bifrost/bifrost-venv
source ~/bifrost/bifrost-venv/bin/activate
pip install --upgrade pip setuptools wheel
cd ~/bifrost/bifrost
pip install .
```

#### 4. **Ansible Errors**

Check Ansible version:
```bash
ansible --version
```

Bifrost requires Ansible 2.10 or later. Update if needed:
```bash
pip install --upgrade ansible
```

#### 5. **Permission Denied Errors**

Add your user to required groups:
```bash
sudo usermod -a -G libvirt $USER
newgrp libvirt
```

### Checking Logs

```bash
# Check Ironic logs
sudo journalctl -u ironic-api
sudo journalctl -u ironic-conductor

# Check system logs
tail -f /var/log/syslog
```

## Next Steps

### 1. Verify Installation

```bash
# Check Ironic services
source ~/bifrost/bifrost-venv/bin/activate
export OS_CLOUD=bifrost

# List nodes
baremetal node list

# Check node details
baremetal node show <node-uuid>
```

### 2. Customize Images

You can use different deployment images:
- Ubuntu Cloud Images
- CentOS Cloud Images
- Custom images built with diskimage-builder

### 3. Production Deployment

For production use:
1. Disable testing mode
2. Configure proper network settings
3. Set up Keystone authentication (optional)
4. Configure HTTPS/TLS
5. Set up proper firewall rules

### 4. Learning Resources

- [Official Bifrost Documentation](https://docs.openstack.org/bifrost/latest/)
- [Bifrost User Guide](https://docs.openstack.org/bifrost/latest/user/index.html)
- [OpenStack Ironic Documentation](https://docs.openstack.org/ironic/latest/)

## WSL-Specific Considerations

### Memory and Resources

Configure WSL to use more resources by creating/editing `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
swap=4GB
```

Restart WSL after making changes:
```powershell
wsl --shutdown
```

### Networking

WSL uses NAT networking by default. For baremetal deployments, you may need to:
1. Configure port forwarding from Windows to WSL
2. Use bridged networking (advanced)
3. Consider using a dedicated Linux machine for production

### Storage

WSL stores files in a virtual disk. For better performance:
- Work within the WSL filesystem (`~` directory)
- Avoid working in `/mnt/c/` when possible

## Quick Reference Commands

```bash
# Activate environment
source ~/bifrost/bifrost-venv/bin/activate

# Check Bifrost status
cd ~/bifrost/bifrost
ansible-playbook -i inventory/target playbooks/test-bifrost.yaml

# List nodes
baremetal node list

# Get node details
baremetal node show <node-name-or-uuid>

# Power management
baremetal node power off <node-name-or-uuid>
baremetal node power on <node-name-or-uuid>

# Rebuild/redeploy
baremetal node rebuild <node-name-or-uuid>
```

## Support and Community

- [Bifrost Bug Reports](https://bugs.launchpad.net/bifrost)
- [OpenStack IRC](https://wiki.openstack.org/wiki/IRC) - #openstack-ironic
- [Mailing Lists](https://lists.openstack.org/cgi-bin/mailman/listinfo)

## License

Bifrost is licensed under the Apache License 2.0.

---

**Note**: This guide is based on the official OpenStack Bifrost documentation. Always refer to the [official documentation](https://docs.openstack.org/bifrost/latest/) for the most up-to-date information.
