#!/bin/bash

#############################################
# Blockchain Node and Blockbook Setup Script
# Based on Documentation.md
#############################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Function to install Docker
install_docker() {
    print_info "Step 1: Installing Docker..."
    
    if command -v docker &> /dev/null; then
        print_success "Docker is already installed"
        docker --version
        return
    fi
    
    print_info "Adding Docker's official GPG key..."
    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release
    
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    print_info "Setting up Docker repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    print_info "Installing Docker Engine..."
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    systemctl start docker
    systemctl enable docker
    
    print_success "Docker installed successfully"
    docker --version
}

# Function to clone Blockbook repository
clone_blockbook() {
    print_info "Step 2: Cloning Blockbook repository..."
    
    if [ -d "blockbook" ]; then
        print_warning "Blockbook directory already exists. Skipping clone..."
        return
    fi
    
    git clone https://github.com/trezor/blockbook
    print_success "Blockbook repository cloned successfully"
}

# Function to build backend
build_backend() {
    local coin=$1
    print_info "Step 3: Building backend for $coin..."
    
    cd blockbook
    make all-$coin
    
    print_success "Backend built successfully for $coin"
}

# Function to install backend package
install_backend() {
    local package_name=$1
    print_info "Step 4: Installing backend package..."
    
    cd build
    apt install -y ./$package_name
    
    print_success "Backend package installed: $package_name"
    cd ..
}

# Function to start backend service
start_backend_service() {
    local service_name=$1
    print_info "Step 5: Starting backend service..."
    
    systemctl start $service_name
    systemctl enable $service_name
    
    print_success "Backend service started: $service_name"
}

# Function to check backend sync status
check_backend_sync() {
    local coin=$1
    local log_path="/opt/coins/data/$coin/backend/debug.log"
    
    print_info "Step 6: Checking backend synchronization status..."
    print_info "Log location: $log_path"
    
    if [ -f "$log_path" ]; then
        print_info "Last 10 lines of debug.log:"
        tail -n 10 "$log_path"
    else
        print_warning "Log file not found yet. Backend may still be initializing..."
    fi
}

# Function to wait for backend sync
wait_for_backend_sync() {
    local coin=$1
    print_warning "Backend needs to fully synchronize before installing Blockbook"
    print_info "This can take several hours to days depending on the blockchain size"
    print_info "Monitor progress at: /opt/coins/data/$coin/backend/debug.log"
    
    read -p "Press Enter when backend is fully synchronized to continue with Blockbook installation..."
}

# Function to install Blockbook
install_blockbook() {
    local package_name=$1
    print_info "Step 7: Installing Blockbook package..."
    
    cd blockbook/build
    apt install -y ./$package_name
    
    print_success "Blockbook package installed: $package_name"
    cd ../..
}

# Function to start Blockbook service
start_blockbook_service() {
    local service_name=$1
    print_info "Step 8: Starting Blockbook service..."
    
    systemctl start $service_name
    systemctl enable $service_name
    
    print_success "Blockbook service started: $service_name"
}

# Function to monitor Blockbook sync
monitor_blockbook() {
    local coin=$1
    local port=$2
    local log_path="/opt/coins/blockbook/$coin/logs/blockbook.INFO"
    
    print_info "Step 9: Monitoring Blockbook synchronization..."
    print_info "Log location: $log_path"
    
    if [ -f "$log_path" ]; then
        print_info "Last 20 lines of blockbook.INFO:"
        tail -n 20 "$log_path"
    else
        print_warning "Log file not found yet. Blockbook may still be initializing..."
    fi
    
    print_info "Access Blockbook UI at: https://localhost:$port"
}

# Main setup function
main() {
    echo "============================================="
    echo "Blockchain Node and Blockbook Setup Script"
    echo "============================================="
    echo ""
    
    check_root
    
    # Prompt user for coin selection
    echo "Select the coin to set up:"
    echo "1) Bitcoin Testnet"
    echo "2) Bitcoin Mainnet"
    echo "3) Litecoin Testnet"
    echo "4) Litecoin Mainnet"
    echo "5) Other (manual input)"
    read -p "Enter your choice (1-5): " coin_choice
    
    case $coin_choice in
        1)
            COIN="bitcoin_testnet"
            BACKEND_SERVICE="backend-bitcoin-testnet.service"
            BLOCKBOOK_SERVICE="blockbook-bitcoin-testnet.service"
            COIN_DATA="bitcoin"
            PUBLIC_PORT="9130"
            ;;
        2)
            COIN="bitcoin"
            BACKEND_SERVICE="backend-bitcoin.service"
            BLOCKBOOK_SERVICE="blockbook-bitcoin.service"
            COIN_DATA="bitcoin"
            PUBLIC_PORT="9130"
            ;;
        3)
            COIN="litecoin_testnet"
            BACKEND_SERVICE="backend-litecoin-testnet.service"
            BLOCKBOOK_SERVICE="blockbook-litecoin-testnet.service"
            COIN_DATA="litecoin"
            PUBLIC_PORT="9335"
            ;;
        4)
            COIN="litecoin"
            BACKEND_SERVICE="backend-litecoin.service"
            BLOCKBOOK_SERVICE="blockbook-litecoin.service"
            COIN_DATA="litecoin"
            PUBLIC_PORT="9333"
            ;;
        5)
            read -p "Enter coin name (e.g., bitcoin_testnet): " COIN
            read -p "Enter backend service name: " BACKEND_SERVICE
            read -p "Enter blockbook service name: " BLOCKBOOK_SERVICE
            read -p "Enter coin data directory name: " COIN_DATA
            read -p "Enter public port: " PUBLIC_PORT
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    echo ""
    print_info "Configuration:"
    print_info "  Coin: $COIN"
    print_info "  Backend Service: $BACKEND_SERVICE"
    print_info "  Blockbook Service: $BLOCKBOOK_SERVICE"
    print_info "  Data Directory: $COIN_DATA"
    print_info "  Public Port: $PUBLIC_PORT"
    echo ""
    
    read -p "Continue with installation? (y/n): " confirm
    if [[ $confirm != "y" && $confirm != "Y" ]]; then
        print_warning "Installation cancelled"
        exit 0
    fi
    
    # Step 1: Install Docker
    install_docker
    echo ""
    
    # Step 2: Clone Blockbook
    clone_blockbook
    echo ""
    
    # Step 3: Build Backend
    build_backend "$COIN"
    echo ""
    
    # Find and install backend package
    cd blockbook/build
    BACKEND_PKG=$(ls backend-${COIN}*.deb 2>/dev/null | head -n 1)
    cd ../..
    
    if [ -z "$BACKEND_PKG" ]; then
        print_error "Backend package not found in build directory"
        exit 1
    fi
    
    print_info "Found backend package: $BACKEND_PKG"
    install_backend "$BACKEND_PKG"
    echo ""
    
    # Step 5: Start Backend Service
    start_backend_service "$BACKEND_SERVICE"
    echo ""
    
    # Step 6: Check Backend Sync
    check_backend_sync "$COIN_DATA"
    echo ""
    
    # Wait for sync
    wait_for_backend_sync "$COIN_DATA"
    echo ""
    
    # Find and install Blockbook package
    cd blockbook/build
    BLOCKBOOK_PKG=$(ls blockbook-${COIN}*.deb 2>/dev/null | head -n 1)
    cd ../..
    
    if [ -z "$BLOCKBOOK_PKG" ]; then
        print_error "Blockbook package not found in build directory"
        exit 1
    fi
    
    print_info "Found Blockbook package: $BLOCKBOOK_PKG"
    install_blockbook "$BLOCKBOOK_PKG"
    echo ""
    
    # Step 8: Start Blockbook Service
    start_blockbook_service "$BLOCKBOOK_SERVICE"
    echo ""
    
    # Step 9: Monitor Blockbook
    monitor_blockbook "$COIN_DATA" "$PUBLIC_PORT"
    echo ""
    
    # Completion
    print_success "============================================="
    print_success "Setup Complete!"
    print_success "============================================="
    print_info "Your blockchain node and Blockbook explorer are now running"
    print_info ""
    print_info "Useful commands:"
    print_info "  Check backend status: systemctl status $BACKEND_SERVICE"
    print_info "  Check Blockbook status: systemctl status $BLOCKBOOK_SERVICE"
    print_info "  View backend logs: tail -f /opt/coins/data/$COIN_DATA/backend/debug.log"
    print_info "  View Blockbook logs: tail -f /opt/coins/blockbook/$COIN_DATA/logs/blockbook.INFO"
    print_info "  Access Blockbook UI: https://localhost:$PUBLIC_PORT"
    print_success "============================================="
}

# Run main function
main
