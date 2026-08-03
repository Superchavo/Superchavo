#!/bin/bash

# Exit immediately if any command fails
set -euo pipefail

# Find the absolute path of the repository root
if [ -d "$(dirname "$0")/NeeXtraRepo" ]; then
    REPO_DIR="$(cd "$(dirname "$0")/NeeXtraRepo" && pwd)"
elif [ -d "$(dirname "$0")/pool" ]; then
    REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
else
    echo "Error: Could not locate NeeXtraRepo directory."
    exit 1
fi

cd "$REPO_DIR"

echo "--- [0/6] Detecting old keyring package version, auto-incrementing, and rebuilding ---"
POOL_DIR="$REPO_DIR/pool"
mkdir -p "$POOL_DIR"

# Find existing neextra-keyring deb files and extract their version
OLD_DEB=$(find "$POOL_DIR" -name "neextra-keyring_*.deb" 2>/dev/null | sort -V | tail -n 1 || true)

NEXT_VERSION="1.0.0"
if [ -n "$OLD_DEB" ]; then
    BASENAME=$(basename "$OLD_DEB")
    CURRENT_VERSION=$(echo "$BASENAME" | sed -E 's/neextra-keyring_(.*)_all\.deb/\1/')
    
    IFS='.' read -r major minor patch <<< "$CURRENT_VERSION"
    if [[ "${patch:-}" =~ ^[0-9]+$ ]]; then
        next_patch=$((patch + 1))
        NEXT_VERSION="$major.$minor.$next_patch"
    else
        NEXT_VERSION="1.0.1"
    fi
    echo "Detected previous version: $CURRENT_VERSION -> Upgrading to: $NEXT_VERSION"
    rm -f "$OLD_DEB"
else
    echo "No previous neextra-keyring package found. Starting with version: $NEXT_VERSION"
fi

# Define paths for building the new package
KEYRING_BUILD_DIR="$REPO_DIR/neextra-keyring-build"
rm -rf "$KEYRING_BUILD_DIR"

mkdir -p "$KEYRING_BUILD_DIR/DEBIAN"
mkdir -p "$KEYRING_BUILD_DIR/data/data/com.termux/files/usr/etc/apt/keyrings"

# Fix permissions so dpkg-deb doesn't complain about 700 permissions
chmod 755 "$KEYRING_BUILD_DIR/DEBIAN"
chmod -R 755 "$KEYRING_BUILD_DIR/data"

if ! command -v gpg &> /dev/null; then
    echo "Error: 'gpg' command is not installed."
    exit 1
fi

echo "Exporting GPG public key as NeextraKey.gpg..."
gpg --armor --export > "$KEYRING_BUILD_DIR/data/data/com.termux/files/usr/etc/apt/keyrings/NeextraKey.gpg"
cp "$KEYRING_BUILD_DIR/data/data/com.termux/files/usr/etc/apt/keyrings/NeextraKey.gpg" "$REPO_DIR/NeextraKey.gpg"

cat << CTRL > "$KEYRING_BUILD_DIR/DEBIAN/control"
Package: neextra-keyring
Version: $NEXT_VERSION
Architecture: all
Maintainer: NeeXtra Repo
Installed-Size: 50
Depends: gnupg
Section: admin
Priority: optional
Homepage: https://github.com/Superchavo/Superchavo
Description: GPG key archive for NeeXtra Repo
 This package contains the digital signature public key (NeextraKey.gpg) used to verify NeeXtra Repo packages.
CTRL

# Ensure control file permissions are also safe
chmod 644 "$KEYRING_BUILD_DIR/DEBIAN/control"

if ! command -v dpkg-deb &> /dev/null; then
    echo "Error: 'dpkg-deb' is not available."
    exit 1
fi

dpkg-deb --build "$KEYRING_BUILD_DIR" "$POOL_DIR/neextra-keyring_${NEXT_VERSION}_all.deb"
rm -rf "$KEYRING_BUILD_DIR"

echo "--- [1/6] Cleaning old indexes ---"
rm -f Packages Packages.gz Packages.xz Release InRelease Release.gpg

echo "--- [2/6] Regenerating package indexes ---"
if ! command -v apt-ftparchive &> /dev/null; then
    echo "Error: 'apt-ftparchive' is not installed. Run 'pkg install apt-utils'."
    exit 1
fi

apt-ftparchive packages ./pool > Packages
gzip -9 -k -f Packages
xz -f -k Packages

echo "--- [3/6] Regenerating Release descriptor ---"
apt-ftparchive \
  -o APT::FTPArchive::Release::Architectures="aarch64 all" \
  -o APT::FTPArchive::Release::Codename="neextra" \
  -o APT::FTPArchive::Release::Components="neextra" \
  -o APT::FTPArchive::Release::Description="The neextrarepo!" \
  -o APT::FTPArchive::Release::Label="NeeXtra Repo" \
  -o APT::FTPArchive::Release::Origin="NeeXtra Repo" \
  -o APT::FTPArchive::Release::Suite="NeextraReleases" \
  -o APT::FTPArchive::Release::Version="1.0" \
  release . > Release

echo "--- [4/6] Signing repository with GPG ---"
gpg --clearsign -o InRelease Release
gpg -abs -o Release.gpg Release

# Return to the main git project root (parent of NeeXtraRepo)
cd ..

echo "--- [5/6] Synchronizing with GitHub ---"
git add .

if git diff-index --quiet HEAD --; then
    echo "No new changes to commit."
    exit 0
fi

echo ""
read -p "Enter your commit message: " commit_msg

if [ -z "$commit_msg" ]; then
    commit_msg="UPDATE: Auto-bumped neextra-keyring to v$NEXT_VERSION, exported NeextraKey.gpg, and refreshed repository metadata"
    echo "No message entered. Using default: '$commit_msg'"
fi

git commit -m "$commit_msg"
git push origin main

echo ""
echo "--- Process completed successfully without errors! ---"
