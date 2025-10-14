# OpenStack Bifrost Installation for Windows WSL Ubuntu

This repository contains everything you need to install and run OpenStack Bifrost on Windows using WSL (Windows Subsystem for Linux) with Ubuntu.

## 📦 What's Included

- **`install_bifrost_wsl.sh`** - Automated installation script
- **`check_prerequisites.sh`** - System requirements verification script
- **`QUICKSTART.md`** - Quick start guide (start here!)
- **`BIFROST_WSL_INSTALLATION_GUIDE.md`** - Comprehensive installation guide

## 🎯 What is Bifrost?

OpenStack Bifrost is a tool designed to simplify the deployment of baremetal servers using OpenStack Ironic. It's perfect for:

- 🖥️ **Bare Metal Provisioning**: Deploy operating systems to physical servers
- 🧪 **Testing and Development**: Test infrastructure deployments in a controlled environment
- 🏗️ **Infrastructure as Code**: Automate server provisioning with Ansible playbooks
- 📊 **Hardware Management**: Manage server power, BIOS settings, and deployments

## 🚀 Getting Started (3 Easy Steps)

### 1️⃣ Check Prerequisites
```bash
./check_prerequisites.sh
```

### 2️⃣ Install Bifrost
```bash
./install_bifrost_wsl.sh
```

### 3️⃣ Start Using Bifrost
```bash
source ~/bifrost/bifrost-venv/bin/activate
cd ~/bifrost/bifrost
```

**That's it!** 🎉

For detailed instructions, see [QUICKSTART.md](QUICKSTART.md)

## 📋 System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **OS** | WSL Ubuntu 20.04 | WSL2 Ubuntu 22.04 |
| **Memory** | 4 GB | 8 GB+ |
| **Disk Space** | 20 GB | 50 GB+ |
| **Python** | 3.8+ | 3.10+ |
| **Ansible** | 2.10+ | Latest |

## 📚 Documentation

### Quick References
- **[QUICKSTART.md](QUICKSTART.md)** - Get up and running in minutes
- **[BIFROST_WSL_INSTALLATION_GUIDE.md](BIFROST_WSL_INSTALLATION_GUIDE.md)** - Complete installation guide with troubleshooting

### Official Documentation
- [Bifrost Documentation](https://docs.openstack.org/bifrost/latest/)
- [OpenStack Ironic Documentation](https://docs.openstack.org/ironic/latest/)

## 🛠️ What Gets Installed

The installation script will set up:

1. **System Dependencies**
   - Python 3, pip, virtualenv
   - Git, build tools, SSL libraries
   - Ansible and related tools
   - Networking utilities

2. **Bifrost Components**
   - Bifrost core from OpenStack repository
   - Python virtual environment
   - Ansible collections and roles
   - Sample configuration files

3. **Configuration Files**
   - `~/bifrost/bifrost-config/bifrost.yml` - Main configuration
   - `~/bifrost/bifrost-config/inventory.yml` - Hardware inventory template

## 📁 Directory Structure

After installation:
```
~/bifrost/
├── bifrost/                    # Bifrost repository
│   ├── playbooks/             # Ansible playbooks
│   ├── roles/                 # Ansible roles
│   └── scripts/               # Utility scripts
├── bifrost-venv/              # Python virtual environment
├── bifrost-config/            # Your configuration files
│   ├── bifrost.yml           # Main config
│   └── inventory.yml         # Node inventory
└── INSTALLATION_INFO.txt      # Installation summary
```

## 🎓 Basic Usage

### Activate Environment
```bash
source ~/bifrost/bifrost-venv/bin/activate
```

### Testing Mode (No Hardware Required)
```bash
cd ~/bifrost/bifrost
ansible-playbook -i inventory/target playbooks/install.yaml -e testing=true
```

### Deploy to Real Hardware
```bash
# 1. Edit your inventory
nano ~/bifrost/bifrost-config/inventory.yml

# 2. Install Bifrost
ansible-playbook -i inventory/target playbooks/install.yaml

# 3. Enroll nodes
ansible-playbook -i inventory/baremetal playbooks/enroll-dynamic.yaml

# 4. Deploy
ansible-playbook -i inventory/baremetal playbooks/deploy-dynamic.yaml
```

### Manage Nodes
```bash
# List all nodes
baremetal node list

# Check node details
baremetal node show <node-name>

# Power management
baremetal node power on <node-name>
baremetal node power off <node-name>
```

## 🐛 Troubleshooting

### Quick Fixes

**Problem: Commands not found**
```bash
source ~/bifrost/bifrost-venv/bin/activate
```

**Problem: Ansible errors**
```bash
source ~/bifrost/bifrost-venv/bin/activate
pip install --upgrade ansible
```

**Problem: Network issues**
```bash
ip addr show
sudo service networking restart
```

**Problem: KVM not available (in WSL)**
```bash
# Use testing mode instead
ansible-playbook -i inventory/target playbooks/install.yaml -e testing=true
```

For more troubleshooting, see [BIFROST_WSL_INSTALLATION_GUIDE.md](BIFROST_WSL_INSTALLATION_GUIDE.md#troubleshooting)

## ⚠️ WSL Limitations

WSL is great for testing and development, but has some limitations:

- **No KVM Support**: Use testing mode or connect to external hardware
- **Networking**: May require port forwarding for external access
- **Performance**: Not suitable for production workloads

For production deployments, consider using a dedicated Linux machine or VM.

## 🤝 Getting Help

### Check These First
1. Run `./check_prerequisites.sh` to verify your system
2. Review the full installation guide in `BIFROST_WSL_INSTALLATION_GUIDE.md`
3. Check Bifrost logs: `sudo journalctl -u ironic-* -f`

### Community Support
- [Bifrost Bug Reports](https://bugs.launchpad.net/bifrost)
- [OpenStack IRC](https://wiki.openstack.org/wiki/IRC) - #openstack-ironic
- [OpenStack Mailing Lists](https://lists.openstack.org/cgi-bin/mailman/listinfo)

## 📝 Configuration Examples

### Basic Configuration (`~/bifrost/bifrost-config/bifrost.yml`)
```yaml
---
network_interface: eth0
enable_keystone: false
noauth_mode: true
testing: false
dhcp_pool_start: 192.168.1.200
dhcp_pool_end: 192.168.1.250
```

### Node Inventory (`~/bifrost/bifrost-config/inventory.yml`)
```yaml
---
server1:
  uuid: "00000000-0000-0000-0000-000000000001"
  driver: "ipmi"
  driver_info:
    power:
      ipmi_address: "192.168.1.100"
      ipmi_username: "admin"
      ipmi_password: "password"
  nics:
    - mac: "00:11:22:33:44:55"
  properties:
    cpu_arch: "x86_64"
    ram: 8192
    disk_size: 100
    cpus: 4
```

## 🔐 Security Notes

- Default configuration uses `noauth_mode` for simplicity
- For production, enable Keystone authentication
- Store credentials securely (use Ansible Vault)
- Configure firewalls appropriately
- Use HTTPS/TLS for API endpoints

## 🎯 Next Steps

1. ✅ Run the prerequisites check
2. ✅ Install Bifrost
3. ✅ Test in testing mode
4. 📝 Customize your configuration
5. 🖥️ Add your hardware inventory
6. 🚀 Deploy your first node

## 📄 License

This installation guide is provided as-is. OpenStack Bifrost is licensed under the Apache License 2.0.

## 🙏 Credits

- **OpenStack Bifrost Team** - For creating this amazing tool
- **OpenStack Community** - For comprehensive documentation
- Based on the [official Bifrost documentation](https://docs.openstack.org/bifrost/latest/)

---

**Ready to get started?** Open [QUICKSTART.md](QUICKSTART.md) or run `./check_prerequisites.sh`!

**Need detailed help?** Check [BIFROST_WSL_INSTALLATION_GUIDE.md](BIFROST_WSL_INSTALLATION_GUIDE.md)!
