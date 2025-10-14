# Bifrost Quick Start Guide for WSL Ubuntu

Get Bifrost up and running on your Windows PC with WSL Ubuntu in minutes!

## 🚀 Quick Installation (3 Steps)

### Step 1: Check Prerequisites
```bash
chmod +x check_prerequisites.sh
./check_prerequisites.sh
```

This will verify that your system meets all requirements.

### Step 2: Run Installation
```bash
chmod +x install_bifrost_wsl.sh
./install_bifrost_wsl.sh
```

This will:
- Install all required dependencies
- Clone the Bifrost repository
- Set up a Python virtual environment
- Install Bifrost and Ansible collections
- Create sample configuration files

Installation takes approximately 10-15 minutes depending on your internet connection.

### Step 3: Activate and Test
```bash
source ~/bifrost/bifrost-venv/bin/activate
cd ~/bifrost/bifrost
ansible-playbook -i inventory/target playbooks/install.yaml -e testing=true
```

## 📋 What You Get

After installation, you'll have:
- ✅ Bifrost installed in `~/bifrost/`
- ✅ Python virtual environment ready to use
- ✅ Sample configuration files in `~/bifrost/bifrost-config/`
- ✅ All required dependencies installed

## 🎯 Common Use Cases

### Testing Mode (No Physical Hardware)
Perfect for learning and testing:
```bash
source ~/bifrost/bifrost-venv/bin/activate
cd ~/bifrost/bifrost
ansible-playbook -i inventory/target playbooks/install.yaml \
    -e testing=true \
    -e enable_keystone=false
```

### Deploying Physical Servers
For actual baremetal deployment:

1. **Edit your inventory** (`~/bifrost/bifrost-config/inventory.yml`):
```yaml
node1:
  uuid: "unique-uuid-here"
  driver: "ipmi"
  driver_info:
    power:
      ipmi_address: "192.168.1.100"
      ipmi_username: "admin"
      ipmi_password: "password"
  nics:
    - mac: "00:11:22:33:44:55"
```

2. **Run the installation**:
```bash
source ~/bifrost/bifrost-venv/bin/activate
cd ~/bifrost/bifrost
ansible-playbook -i inventory/target playbooks/install.yaml
```

3. **Enroll your nodes**:
```bash
ansible-playbook -i inventory/baremetal playbooks/enroll-dynamic.yaml
```

4. **Deploy nodes**:
```bash
ansible-playbook -i inventory/baremetal playbooks/deploy-dynamic.yaml
```

## 🔧 Essential Commands

### Activate Environment
Always run this first:
```bash
source ~/bifrost/bifrost-venv/bin/activate
```

### Check Node Status
```bash
baremetal node list
baremetal node show <node-name>
```

### Power Management
```bash
baremetal node power on <node-name>
baremetal node power off <node-name>
baremetal node power status <node-name>
```

### Viewing Logs
```bash
sudo journalctl -u ironic-api -f
sudo journalctl -u ironic-conductor -f
```

## 🐛 Common Issues & Quick Fixes

### Issue: "Command not found: baremetal"
**Fix:** Activate the virtual environment
```bash
source ~/bifrost/bifrost-venv/bin/activate
```

### Issue: Ansible fails with "No module named X"
**Fix:** Reinstall in the virtual environment
```bash
source ~/bifrost/bifrost-venv/bin/activate
pip install --upgrade ansible
```

### Issue: KVM/libvirt errors in WSL
**Fix:** Use testing mode (WSL doesn't support KVM)
```bash
ansible-playbook -i inventory/target playbooks/install.yaml -e testing=true
```

### Issue: Network connectivity problems
**Fix:** Check your WSL network configuration
```bash
ip addr show
sudo service networking restart
```

## 📚 Next Steps

1. **Read the Full Guide**: Check `BIFROST_WSL_INSTALLATION_GUIDE.md` for detailed documentation
2. **Customize Configuration**: Edit files in `~/bifrost/bifrost-config/`
3. **Learn More**: Visit [Bifrost Documentation](https://docs.openstack.org/bifrost/latest/)

## 💡 Pro Tips

- **Always use the virtual environment**: Run `source ~/bifrost/bifrost-venv/bin/activate` before any Bifrost commands
- **Keep configurations in one place**: Store all your custom configs in `~/bifrost/bifrost-config/`
- **Check logs regularly**: Use `journalctl` to monitor Ironic services
- **Start with testing mode**: Get familiar with Bifrost using testing mode before deploying to real hardware

## 🆘 Need Help?

- Check the full installation guide: `BIFROST_WSL_INSTALLATION_GUIDE.md`
- Run the prerequisites check again: `./check_prerequisites.sh`
- Review Bifrost logs: `sudo journalctl -u ironic-* -f`
- Official documentation: https://docs.openstack.org/bifrost/latest/

## 📝 Configuration Files Reference

| File | Purpose | Location |
|------|---------|----------|
| `bifrost.yml` | Main configuration | `~/bifrost/bifrost-config/bifrost.yml` |
| `inventory.yml` | Hardware inventory | `~/bifrost/bifrost-config/inventory.yml` |
| `install.yaml` | Installation playbook | `~/bifrost/bifrost/playbooks/install.yaml` |
| `enroll-dynamic.yaml` | Node enrollment | `~/bifrost/bifrost/playbooks/enroll-dynamic.yaml` |

---

**Ready to go?** Start with `./check_prerequisites.sh` and follow the steps above!
