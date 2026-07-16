#!/bin/bash

# Asegurarse de estar en la carpeta donde esta el repo
cd "$(dirname "$0")/NeeXtraRepo" || exit

echo "--- Limpiando índices antiguos ---"
rm -f Packages Packages.gz Packages.xz Release InRelease Release.gpg

echo "--- Regenerando índices ---"
apt-ftparchive packages ./pool > Packages
gzip -9 -k -f Packages
xz -f -k Packages

echo "--- Regenerando descriptor Release ---"
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

echo "--- Firmando repositorio ---"
gpg --clearsign -o InRelease Release
gpg -abs -o Release.gpg Release

echo "--- Subiendo a GitHub ---"
cd ..
git add .
git commit -m "UPDATE: Added TermuxDM v6 and removed v5.0"
git push origin main

echo "--- ¡Proceso finalizado con éxito! ---"
