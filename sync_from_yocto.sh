#!/bin/bash

# Script to sync packages from Yocto build output to the repository
# Usage: ./sync_from_yocto.sh <yocto-deploy-ipk-path>

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <yocto-deploy-ipk-path>"
    echo "Example: $0 /path/to/build/tmp/deploy/ipk"
    echo ""
    echo "This script will copy IPK files from your Yocto build output"
    echo "to the appropriate architecture directories in this repository."
    exit 1
fi

YOCTO_IPK_DIR="$1"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$YOCTO_IPK_DIR" ]; then
    echo "Error: Yocto IPK directory '$YOCTO_IPK_DIR' not found"
    echo "Make sure you've built your Yocto image first"
    exit 1
fi

echo "Syncing packages from: $YOCTO_IPK_DIR"
echo "To repository: $REPO_ROOT"
echo ""

# Copy packages from each architecture
for arch_dir in "$YOCTO_IPK_DIR"/*/; do
    if [ -d "$arch_dir" ]; then
        arch=$(basename "$arch_dir")
        echo "Processing architecture: $arch"
        
        # Create target directory if it doesn't exist
        target_dir="$REPO_ROOT/ipk/$arch"
        if [ ! -d "$target_dir" ]; then
            echo "  Creating directory: $target_dir"
            mkdir -p "$target_dir"
            echo "# Package index for architecture '$arch'" > "$target_dir/Packages"
        fi
        
        # Count and copy IPK files
        ipk_count=0
        for ipk_file in "$arch_dir"/*.ipk; do
            if [ -f "$ipk_file" ]; then
                cp "$ipk_file" "$target_dir/"
                ((ipk_count++))
            fi
        done
        
        echo "  Copied $ipk_count packages"
    fi
done

echo ""
echo "Sync completed!"
echo "Run ./update_packages.sh to regenerate package indexes"