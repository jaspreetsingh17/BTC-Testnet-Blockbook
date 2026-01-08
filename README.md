# Blockbook Setup & Deployment

A comprehensive setup guide and automation tools for deploying [Blockbook](https://github.com/trezor/blockbook) - a blockchain indexer and explorer back-end service for Trezor Suite with support for multiple cryptocurrencies.

## Overview

This repository contains:
- **Automated setup script** for quick deployment of Blockbook and blockchain nodes
- **Detailed documentation** of manual setup procedures
- **TypeScript API definitions** for Blockbook integration
- **Pre-configured build files** for various blockchain networks

Blockbook provides fast blockchain indexing, address balance tracking, and API endpoints for Bitcoin, Ethereum, and 30+ other cryptocurrencies.

## Features

- **One-click automated deployment** with interactive setup script
- Support for **Bitcoin, Ethereum, and 30+ cryptocurrencies**
- Fast address and transaction indexing
- RESTful API with WebSocket support
- Built-in blockchain explorer interface
- TypeScript type definitions for API integration
- Comprehensive setup documentation

## Quick Start

### Prerequisites

- **OS**: Debian-based Linux (Ubuntu, Debian)
- **Architecture**: AMD64/x86_64
- **RAM**: 32 GB minimum (for Bitcoin mainnet)
- **Storage**: 180+ GB SSD (varies by blockchain)
- **Permissions**: Root/sudo access

### Automated Installation

```bash
# Clone the repository
git clone https://github.com/jaspreetsingh17/BTC-Testnet-Blockbook.git
cd BTC-Testnet-Blockbook

# Make the setup script executable
chmod +x setup-blockbook.sh

# Run the automated setup (as root)
sudo ./setup-blockbook.sh
```

The script will guide you through:
1. Docker installation
2. Blockbook repository cloning
3. Backend building for your chosen cryptocurrency
4. Package installation
5. Service configuration and startup
6. Synchronization monitoring

### Manual Installation

For step-by-step manual setup instructions, see [Documentation.md](Documentation.md).

## Repository Structure

```
.
├── README.md                    # This file
├── Documentation.md             # Detailed manual setup guide
├── setup-blockbook.sh          # Automated installation script
├── blockbook/                   # Blockbook source code
│   ├── blockbook-api.ts        # TypeScript API definitions
│   ├── api/                    # API implementation
│   ├── bchain/                 # Blockchain interfaces
│   ├── configs/                # Coin configurations
│   ├── docs/                   # Documentation
│   └── ...
```

## Configuration

### Supported Coins

Blockbook supports **30+ cryptocurrencies** including:

**Bitcoin Family:**
- Bitcoin (BTC) - Mainnet & Testnet
- Bitcoin Cash (BCH)
- Litecoin (LTC)
- Dogecoin (DOGE)
- Bitcoin Gold (BTG)

**Ethereum Family:**
- Ethereum (ETH) - Mainnet & Testnets
- Ethereum Classic (ETC)
- Binance Smart Chain (BSC)
- Avalanche (AVAX)
- Arbitrum, Base, Optimism

**Others:**
- Dash, Zcash, Vertcoin, DigiByte, Liquid, and more

See [docs/ports.md](blockbook/docs/ports.md) for the complete list.

### Build Commands

To build backend for specific coins:

```bash
cd blockbook

# Bitcoin mainnet
make all-bitcoin

# Bitcoin testnet
make all-bitcoin_testnet

# Ethereum
make all-ethereum

# Other coins
make all-<coin-name>
```

## API Integration

### TypeScript Support

Use the provided TypeScript definitions for type-safe API integration:

```typescript
import { Address, Transaction, Block } from './blockbook/blockbook-api';

// Example: Fetch address information
async function getAddressInfo(address: string): Promise<Address> {
  const response = await fetch(`http://localhost:9130/api/v2/address/${address}`);
  return await response.json();
}
```

### API Endpoints

Once Blockbook is running, access the API at:

- **REST API**: `http://localhost:9130/api/v2/`
- **WebSocket**: `ws://localhost:9130/websocket`
- **Explorer UI**: `http://localhost:9130/`

API documentation: [blockbook/docs/api.md](blockbook/docs/api.md)

## System Requirements by Coin

| Coin | RAM | Disk Space | Sync Time |
|------|-----|------------|-----------|
| Bitcoin (BTC) | 32 GB | 180+ GB | 2-3 days |
| Ethereum (ETH) | 16 GB | 120+ GB | 1-2 days |
| Bitcoin Testnet | 8 GB | 30+ GB | Hours |
| Litecoin (LTC) | 16 GB | 60+ GB | 1 day |

*Requirements vary based on network size and growth. SSD strongly recommended.*

## Monitoring & Management

### Check Backend Status

```bash
# Check service status
systemctl status backend-<coin>.service

# View sync logs
tail -f /opt/coins/data/<coin>/backend/debug.log

# Check Blockbook status
systemctl status blockbook-<coin>.service
```

### Service Management

```bash
# Start services
systemctl start backend-<coin>.service
systemctl start blockbook-<coin>.service

# Stop services
systemctl stop backend-<coin>.service
systemctl stop blockbook-<coin>.service

# Restart services
systemctl restart backend-<coin>.service
systemctl restart blockbook-<coin>.service
```

## Troubleshooting

### Out of Memory During Initial Sync

Reduce memory footprint:

```bash
# Disable RocksDB cache
blockbook -dbcache=0

# Run with single worker
blockbook -workers=1
```

### Slow Synchronization

- Ensure you're using SSD storage
- Check available RAM (use `htop` or `free -h`)
- Verify network connectivity to peer nodes
- Monitor CPU usage - consider upgrading if consistently maxed

### Service Won't Start

```bash
# Check logs
journalctl -u backend-<coin>.service -n 100
journalctl -u blockbook-<coin>.service -n 100

# Verify package installation
dpkg -l | grep backend
dpkg -l | grep blockbook
```

## Documentation

- [Build Guide](blockbook/docs/build.md) - Developer build instructions
- [API Documentation](blockbook/docs/api.md) - API reference
- [Configuration Guide](blockbook/docs/config.md) - Configuration options
- [Ports Registry](blockbook/docs/ports.md) - Supported coins and ports
- [Testing Guide](blockbook/docs/testing.md) - Running tests

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](blockbook/CONTRIBUTING.md) for guidelines.

## License

This setup repository is provided as-is. Blockbook is licensed under [AGPL-3.0](blockbook/COPYING).

## Credits

- **Blockbook**: [Trezor/SatoshiLabs](https://github.com/trezor/blockbook)
- **Setup Scripts**: Custom automation for simplified deployment

## Support

For Blockbook-specific issues, please refer to:
- [Official Blockbook Repository](https://github.com/trezor/blockbook)
- [Trezor Wiki](https://wiki.trezor.io/)

For setup script issues, please open an issue in this repository.

---

**Note**: This is a third-party setup repository. For official Blockbook support, visit the [Trezor Blockbook repository](https://github.com/trezor/blockbook).

