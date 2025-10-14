#!/bin/bash

# Prerequisites Check Script for Bifrost on WSL Ubuntu
# Run this before installing Bifrost to ensure your system is ready

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS=0
FAIL=0
WARN=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Bifrost Prerequisites Check${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print check results
check_pass() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASS++))
}

check_fail() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAIL++))
}

check_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
    ((WARN++))
}

# Check if running on WSL
echo "Checking WSL environment..."
if grep -qi microsoft /proc/version; then
    check_pass "Running on WSL"
    
    # Check WSL version
    if grep -qi "WSL2" /proc/version; then
        check_pass "WSL2 detected (recommended)"
    else
        check_warn "WSL1 detected. WSL2 is recommended for better performance"
    fi
else
    check_warn "Not running on WSL (this is okay if you're on native Linux)"
fi
echo ""

# Check Ubuntu version
echo "Checking OS version..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
        check_pass "Ubuntu detected: $VERSION"
        
        VERSION_NUMBER=$(echo $VERSION_ID | cut -d. -f1)
        if [ "$VERSION_NUMBER" -ge 20 ]; then
            check_pass "Ubuntu version is 20.04 or newer"
        else
            check_warn "Ubuntu 20.04 or newer is recommended"
        fi
    else
        check_warn "Not running Ubuntu. This script is optimized for Ubuntu."
    fi
else
    check_fail "Cannot determine OS version"
fi
echo ""

# Check memory
echo "Checking system resources..."
TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_MEM" -ge 4 ]; then
    check_pass "Sufficient memory: ${TOTAL_MEM}GB (minimum 4GB)"
else
    check_warn "Low memory: ${TOTAL_MEM}GB. 4GB or more recommended"
fi

# Check disk space
AVAILABLE_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -ge 20 ]; then
    check_pass "Sufficient disk space: ${AVAILABLE_SPACE}GB available (minimum 20GB)"
else
    check_fail "Insufficient disk space: ${AVAILABLE_SPACE}GB. Need at least 20GB"
fi
echo ""

# Check Python
echo "Checking Python installation..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    check_pass "Python3 installed: $PYTHON_VERSION"
    
    # Check Python version (need 3.8+)
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)
    
    if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 8 ]; then
        check_pass "Python version is 3.8 or newer"
    else
        check_warn "Python 3.8+ is recommended. Found: $PYTHON_VERSION"
    fi
else
    check_fail "Python3 not installed"
fi

# Check pip
if command -v pip3 &> /dev/null; then
    PIP_VERSION=$(pip3 --version | awk '{print $2}')
    check_pass "pip3 installed: $PIP_VERSION"
else
    check_fail "pip3 not installed"
fi
echo ""

# Check git
echo "Checking version control..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    check_pass "git installed: $GIT_VERSION"
else
    check_fail "git not installed"
fi
echo ""

# Check network connectivity
echo "Checking network connectivity..."
if ping -c 1 8.8.8.8 &> /dev/null; then
    check_pass "Internet connectivity available"
else
    check_fail "No internet connectivity"
fi

if ping -c 1 opendev.org &> /dev/null; then
    check_pass "Can reach opendev.org (Bifrost repository)"
else
    check_warn "Cannot reach opendev.org. May have DNS issues"
fi
echo ""

# Check for required packages
echo "Checking for required packages..."
REQUIRED_PACKAGES=(
    "build-essential"
    "libssl-dev"
    "libffi-dev"
)

for package in "${REQUIRED_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package"; then
        check_pass "$package is installed"
    else
        check_warn "$package is not installed (will be installed during setup)"
    fi
done
echo ""

# Check if Ansible is installed
echo "Checking Ansible..."
if command -v ansible &> /dev/null; then
    ANSIBLE_VERSION=$(ansible --version | head -n1 | awk '{print $2}')
    check_pass "Ansible installed: $ANSIBLE_VERSION"
    
    # Check Ansible version (need 2.10+)
    ANSIBLE_MAJOR=$(echo $ANSIBLE_VERSION | cut -d. -f1)
    ANSIBLE_MINOR=$(echo $ANSIBLE_VERSION | cut -d. -f2)
    
    if [ "$ANSIBLE_MAJOR" -ge 2 ] && [ "$ANSIBLE_MINOR" -ge 10 ] || [ "$ANSIBLE_MAJOR" -gt 2 ]; then
        check_pass "Ansible version is 2.10 or newer"
    else
        check_warn "Ansible 2.10+ is recommended. Found: $ANSIBLE_VERSION"
    fi
else
    check_warn "Ansible not installed (will be installed during setup)"
fi
echo ""

# Check virtualization support (nice to have, not critical in WSL)
echo "Checking virtualization support..."
if [ -e /dev/kvm ]; then
    check_pass "KVM device available"
else
    check_warn "KVM not available (expected in WSL, can use testing mode)"
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Prerequisites Check Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Passed:  $PASS${NC}"
echo -e "${YELLOW}Warnings: $WARN${NC}"
echo -e "${RED}Failed:   $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ Your system appears ready for Bifrost installation!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run the installation script: ./install_bifrost_wsl.sh"
    echo "  2. Or follow the manual installation guide in BIFROST_WSL_INSTALLATION_GUIDE.md"
    exit 0
else
    echo -e "${RED}✗ Please address the failed checks before installing Bifrost${NC}"
    echo ""
    echo "To fix common issues:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y python3 python3-pip git build-essential"
    exit 1
fi
