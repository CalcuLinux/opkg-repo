# Calculinux OPKG Repository

This repository serves as an OPKG package repository for Calculinux, the Linux distribution for Picocalc devices, hosted via GitHub Pages. It provides a centralized location for distributing IPK packages that can be installed on Picocalc devices running Calculinux.

## Repository Structure

```
opkg-repo/
├── ipk/                    # Package files organized by architecture
│   ├── all/               # Architecture-independent packages
│   ├── luckfox-lyra/      # ARM packages for Luckfox Lyra
│   ├── any/               # Cross-platform packages
│   └── noarch/            # Data-only packages
├── scripts/
│   ├── add_package.sh     # Add a single IPK package
│   ├── sync_from_yocto.sh # Sync packages from Yocto build
│   └── update_packages.sh # Regenerate package indexes
├── .github/workflows/     # GitHub Actions for auto-deployment
└── index.html            # Repository web interface
```

## Quick Start

### 1. Setting Up GitHub Repository

1. Push this repository to GitHub:
   ```bash
   git remote add origin https://github.com/calculinux/opkg-repo.git
   git branch -M main
   git push -u origin main
   ```

2. Enable GitHub Pages:
   - Go to your repository settings
   - Navigate to "Pages" section
   - Source: "GitHub Actions"
   - The repository will be available at: `https://opkg.calculinux.org`

### 2. Adding Packages

#### From Yocto Build Output
```bash
# Sync all packages from your Yocto build
./sync_from_yocto.sh /path/to/build/tmp/deploy/ipk

# Update package indexes
./update_packages.sh

# Commit and push
git add .
git commit -m "Add packages from Yocto build"
git push
```

#### Individual Package
```bash
# Add a single IPK file
./add_package.sh /path/to/package_1.0_luckfox-lyra.ipk

# Update package indexes
./update_packages.sh

# Commit and push
git add .
git commit -m "Add new package"
git push
```

### 3. Configuring Devices

Update your device's `/etc/opkg/opkg.conf` file:

```bash
# Add these lines (replace calculinux with your GitHub username)
src/gz all https://opkg.calculinux.org/ipk/all
src/gz luckfox-lyra https://opkg.calculinux.org/ipk/luckfox-lyra
src/gz any https://opkg.calculinux.org/ipk/any
src/gz noarch https://opkg.calculinux.org/ipk/noarch
```

## Usage on Target Device

```bash
# Update package lists
opkg update

# List available packages
opkg list

# Search for a package
opkg list | grep package-name

# Install a package
opkg install package-name

# Remove a package
opkg remove package-name

# Show package information
opkg info package-name

# List installed packages
opkg list-installed
```

## Scripts Reference

### `add_package.sh`
Adds a single IPK package to the repository.

**Usage:** `./add_package.sh <path-to-ipk-file>`

- Automatically detects architecture from filename
- Copies package to appropriate directory
- Requires manual `update_packages.sh` run afterward

### `sync_from_yocto.sh`
Syncs all packages from a Yocto build output directory.

**Usage:** `./sync_from_yocto.sh <yocto-deploy-ipk-path>`

- Copies all IPK files from Yocto's tmp/deploy/ipk directory
- Maintains architecture structure
- Requires manual `update_packages.sh` run afterward

### `update_packages.sh`
Regenerates package indexes for all architectures.

**Usage:** `./update_packages.sh`

- Scans all IPK files in each architecture directory
- Extracts package metadata from control files
- Generates both Packages and Packages.gz files
- Run this after adding or removing packages

## Automated Deployment

The repository includes GitHub Actions workflow (`.github/workflows/deploy.yml`) that:

1. Automatically builds and deploys to GitHub Pages on push to main branch
2. Generates compressed package indexes
3. Makes the repository available via HTTPS

## Architecture Support

- **all**: Packages that work on all architectures
- **luckfox-lyra**: ARM packages specific to Luckfox Lyra platform
- **any**: Architecture-independent packages
- **noarch**: Data-only packages without architecture dependencies

## Package Naming Convention

IPK files should follow this naming convention:
```
package-name_version_architecture.ipk
```

Examples:
- `my-app_1.0.0_luckfox-lyra.ipk`
- `config-files_1.0_all.ipk`
- `documentation_1.0_noarch.ipk`

## Troubleshooting

### Package Not Found
- Ensure package indexes are up to date: run `opkg update`
- Check if the package exists in the correct architecture directory
- Verify repository URLs in `/etc/opkg/opkg.conf`

### GitHub Pages Not Updating
- Check GitHub Actions tab for deployment status
- Ensure the repository has GitHub Pages enabled
- Verify workflow has proper permissions

### Invalid Package Format
- Ensure IPK files are valid ar archives
- Check that control.tar.gz exists and contains valid control file
- Verify package naming follows conventions

## Contributing

1. Fork this repository
2. Add your packages using the provided scripts
3. Test the changes locally
4. Submit a pull request

## License

This repository structure and scripts are provided under the MIT License. Individual packages may have their own licenses.