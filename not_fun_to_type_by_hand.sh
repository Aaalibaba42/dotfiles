#!/bin/sh

set -e

echo "Installing Rust..."
rustup install stable
echo "Finished installing Rust!"

echo "Installing paru..."
tmpdir=$(mktemp -d)
git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
cd "$tmpdir/paru/"
makepkg -si
cd -
rm -r "$tmpdir/paru/"
echo "Finished installing Paru!"


echo "Setting up chaotic AUR..."
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo "Finished setting up chaotic AUR!"

echo "Some of the things we did require full system resync and upgrade."
sudo pacman -Syyu
