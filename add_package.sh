#!/bin/bash

# Script to add IPK packages to the repository and update package indexes
# Usage: ./add_package.sh <path-to-ipk-file>

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <path-to-ipk-file>"
    echo "Example: $0 /path/to/package_1.0_luckfox-lyra.ipk"
    exit 1
fi

IPK_FILE="$1"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f "$IPK_FILE" ]; then
    echo "Error: IPK file '$IPK_FILE' not found"
    exit 1
fi

# Extract package information
BASENAME=$(basename "$IPK_FILE")
echo "Processing package: $BASENAME"

# Extract architecture from filename
# Expected format: package_version_architecture.ipk
ARCH=$(echo "$BASENAME" | sed -n 's/.*_\([^_]*\)\.ipk$/\1/p')

if [ -z "$ARCH" ]; then
    echo "Warning: Could not determine architecture from filename. Using 'all'"
    ARCH="all"
fi

echo "Detected architecture: $ARCH"

# Validate architecture directory exists
ARCH_DIR="$REPO_ROOT/ipk/$ARCH"
if [ ! -d "$ARCH_DIR" ]; then
    echo "Creating directory for architecture: $ARCH"
    mkdir -p "$ARCH_DIR"
    echo "# Package index for architecture '$ARCH'" > "$ARCH_DIR/Packages"
fi

# Copy the IPK file
echo "Copying $IPK_FILE to $ARCH_DIR/"
cp "$IPK_FILE" "$ARCH_DIR/"

echo "Package added successfully!"
echo "Run ./update_packages.sh to regenerate package indexes"