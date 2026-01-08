# Blockchain Node Setup Documentation

This document outlines the steps followed to set up a full blockchain node and Blockbook indexer.

---

## 1. Install Docker

Follow the official Docker installation guide for Debian-based systems:

* Refer to the Docker documentation for installation steps.
* Ensure Docker Engine (docker-ce) is successfully installed and running.

---

## 2. Clone the Blockbook Repository

Clone the official Blockbook repository from GitHub:

```bash
git clone https://github.com/trezor/blockbook
```

---

## 3. Build Backend for the Desired Coin

Navigate into the cloned Blockbook directory:

```bash
cd blockbook
```

Run the appropriate build command for your coin:

```bash
make all-<coin>
```

For example:

```bash
make all-bitcoin_testnet
```

---

## 4. Install Backend Package

Navigate to the build directory:

```bash
cd build
```

Install the backend package:

```bash
apt install ./<backend-package-name>.deb
```

Example:

```bash
apt install ./backend-bitcoin_testnet_0.16.1-satoshilabs1_amd64.deb
```

---

## 5. Start Backend Service

Start the backend daemon to begin blockchain synchronization:

```bash
systemctl start backend-<coin>.service
```

Example:

```bash
systemctl start backend-bitcoin-testnet.service
```

---

## 6. Check Synchronization Status

View sync status in the backend log directory:

```
/opt/coins/data/<coin>/backend
```

Check the `debug.log` file for progress.

Example:

```
/opt/coins/data/bitcoin/backend/debug.log
```

---

## 7. Install Blockbook

After the blockchain backend is fully synchronized, install Blockbook:

```bash
apt install ./<blockbook-package>.deb
```

Example:

```bash
apt install ./blockbook-bitcoin_testnet_0.0.6_amd64.deb
```

---

## 8. Start Blockbook Service

Start the Blockbook indexer:

```bash
systemctl start blockbook-<coin>.service
```

Example:

```bash
systemctl start blockbook-bitcoin-testnet.service
```

---

## 9. Monitor Blockbook Synchronization

Check Blockbook logs:

```
/opt/coins/blockbook/<coin>/logs/blockbook.INFO
```

Example:

```
/opt/coins/blockbook/bitcoin/logs/blockbook.INFO
```

You may also view the local explorer UI:

```
https://localhost:<public-port>
```

Example:

```
https://localhost:9130
```

---

## 10. Completion

After full synchronization, Blockbook and the backend node are fully operational and available on localhost.

---

**Your blockchain node and Blockbook explorer are now successfully set up and running.**
