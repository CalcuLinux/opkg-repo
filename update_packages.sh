#!/bin/bash

# Script to update package indexes for all architectures
# This script scans for IPK files and generates the Packages index files

set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "Updating package indexes..."

# Function to extract package info from IPK file
extract_package_info() {
    local ipk_file="$1"
    local temp_dir=$(mktemp -d)
    
    # Extract the control.tar.gz from the IPK
    cd "$temp_dir"
    ar x "$ipk_file" 2>/dev/null || {
        echo "Warning: Failed to extract $ipk_file" >&2
        rm -rf "$temp_dir"
        return 1
    }
    
    # Extract control information
    if [ -f "control.tar.gz" ]; then
        tar -xzf control.tar.gz 2>/dev/null || {
            echo "Warning: Failed to extract control info from $ipk_file" >&2
            rm -rf "$temp_dir"
            return 1
        }
    elif [ -f "control.tar.xz" ]; then
        tar -xJf control.tar.xz 2>/dev/null || {
            echo "Warning: Failed to extract control info from $ipk_file" >&2
            rm -rf "$temp_dir"
            return 1
        }
    else
        echo "Warning: No control archive found in $ipk_file" >&2
        rm -rf "$temp_dir"
        return 1
    fi
    
    if [ -f "control" ]; then
        # Add filename and size information
        echo "Filename: $(basename "$ipk_file")"
        echo "Size: $(stat -c%s "$ipk_file")"
        cat control
        echo ""  # Empty line to separate packages
    fi
    
    rm -rf "$temp_dir"
}

# Process each architecture directory
for arch_dir in "$REPO_ROOT"/ipk/*/; do
    if [ -d "$arch_dir" ]; then
        arch=$(basename "$arch_dir")
        echo "Processing architecture: $arch"
        
        packages_file="$arch_dir/Packages"
        temp_packages=$(mktemp)
        
        # Add header
        echo "# Package index for architecture '$arch'" > "$temp_packages"
        echo "# Generated on $(date)" >> "$temp_packages"
        echo "" >> "$temp_packages"
        
        # Process all IPK files in this directory
        ipk_count=0
        for ipk_file in "$arch_dir"/*.ipk; do
            if [ -f "$ipk_file" ]; then
                echo "  Processing: $(basename "$ipk_file")"
                extract_package_info "$ipk_file" >> "$temp_packages" || true
                ((ipk_count++))
            fi
        done
        
        # Update the Packages file
        mv "$temp_packages" "$packages_file"
        
        # Create compressed version
        gzip -c "$packages_file" > "$packages_file.gz"
        
        echo "  Found $ipk_count packages for $arch"
    fi
done

echo ""
echo "Package indexes updated successfully!"
echo "Compressed indexes (.gz) created for web serving"