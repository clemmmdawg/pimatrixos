#!/usr/bin/env bash
set -e

echo "=== PiMatrixOS Automated Installer ==="
echo "Target OS: Raspberry Pi OS Lite (32-bit)"
echo

# Require sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this installer with sudo:"
  echo "  sudo ./install.sh"
  exit 1
fi

echo "==> Updating system..."
apt update
apt upgrade -y

echo "==> Installing required packages..."
apt install -y \
  git \
  build-essential \
  python3 \
  python3-pil \
  python3-dev \
  python3-pip \
  swig \
  cython3 \
  python3-setuptools \
  python3-wheel

# Resolve the directory containing this script. If it's sitting inside a
# PiMatrixOS checkout (i.e. launcher.py is right next to it), use that as
# the install dir; otherwise clone a fresh copy next to the script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/launcher.py" ]; then
  PIMATRIXOS_DIR="$SCRIPT_DIR"
else
  cd "$SCRIPT_DIR" || exit 1
  echo "==> Installing PiMatrixOS..."
  if [ ! -d pimatrixos ]; then
    git clone https://github.com/dominikelektricar/pimatrixos.git
  fi
  PIMATRIXOS_DIR="$SCRIPT_DIR/pimatrixos"
fi

cd "$SCRIPT_DIR" || exit 1

echo "==> Installing rpi-rgb-led-matrix..."
if [ ! -d rpi-rgb-led-matrix ]; then
  git clone https://github.com/hzeller/rpi-rgb-led-matrix.git
fi

cd rpi-rgb-led-matrix
make

# The Python bindings are installed via pip from the repo root (the old
# "make build-python && setup.py install" flow in bindings/python no
# longer exists upstream).
pip install . --break-system-packages

cd "$PIMATRIXOS_DIR" || exit 1
chmod +x launcher.py

echo
echo "✅ PiMatrixOS installation complete."
echo
echo "To start PiMatrixOS:"
echo "  cd $PIMATRIXOS_DIR"
echo "  sudo python3 launcher.py"
