#!/bin/sh

user="$(whoami)"
# `path//to//file` are valid posix file paths, I'd rather double them
# most of the time and everything still work when I forget one
# than breaking something for a small mistake
home="/home/$user/"
hsh="$home/hsh/"
config="$home/.config/"
ssh="$home/.ssh/"
dotfiles_rep="$hsh/workspace/perso/dotfiles"
tmpdir=$(mktemp -d)

install_bins() {
  to_install=""
  for bin in "$@"; do
    if [ ! -x "$(which "$bin")" ]; then
      to_install="$to_install:$bin"
    else
      echo "'$bin' already installed, skipping..." >&2
    fi
  done

  doas pacman --no-confirm -S $to_install
}

# Add stuff here when you create artifacts. Use absolute path here since
# we have no guarantees where the user is.
safe_cleanup() {
  echo "Cleaning up..."

  doas rm -rf "$tmpdir"

  # Remove the no password option
  echo "permit $user as root" | doas tee /etc/doas.conf

  echo "Done cleaning!"
}

if [ "$(whoami)" = "root" ]; then
  echo "Do not run this script as super user"
  exit 1
fi

# I *think* it's okay to be anywhere, since I use absolute paths
# everywhere, but I'd rather the user (me) respect such a basic
# constraint
if [ "$(pwd)" != "/home/$(whoami)" ]; then
  echo "This script should be run in home of the user"
  exit 1
fi

echo "Installing doas..."
if [ ! -x "$(which doas)" ]; then
  if [ ! -x "$(which sudo)" ]; then
    echo "Neither sudo nor doas seem to be installed."
    exit 1
  fi

  sudo pacman -S doas
  echo "permit nopass $user as root" | sudo tee /etc/doas.conf
  # This is kinda dirty, but it's written in the archwiki so ima trust
  # it
  doas ln -s "$(which doas)" /usr/bin/sudo
fi
echo "Finished installing doas!"

echo "Cloning dotfiles..."
mkdir -p "$dotfiles_rep"
install_bin git
git clone git@github.com:Aaalibaba42/dotfiles.git "$dotfiles_rep"
echo "Cloned dotfiles!"

# We want to have parralel Downloads before installing stuff required,
# so it's better to start by moving at least that part of the config
echo "Activating Parrallel Downloads"
cp "$dotfiles_rep/etc/pacman.conf" /etc/pacman.conf
echo "Parrellel Downloads activated!"

echo "Setting up chaotic AUR..."
doas pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
doas pacman-key --lsign-key 3056513887B78AEB

doas pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
doas pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

printf "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | doas tee -a /etc/pacman.conf
echo "Finished setting up chaotic AUR!"

echo "Installing truckload of stuff..."
# I actually *need* word splitting here, the pacman.packages should not
# contain spaces.
doas pacman -S $(tr '\n' ' ' < "$dotfiles_rep/pacman.packages")
echo "Finished installing truckload of stuff!"

echo "Installing Rust (required for paru)..."
rustup install stable
echo "Finished installing Rust!"

echo "Installing paru..."
git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
makepkg -si -D "$tmpdir/paru/"
echo "Finished installing Paru!"

echo "Installing AUR packages"
doas pacman -S $(tr '\n' ' ' < "$dotfiles_rep/pacman.packages")
echo "Finished install of AUR packages!"

# TODO config symlinks

# TODO nix

# groups/user config
echo "Creating groups and attributing them to $user..."
doas group add nix-users docker
doas usermod -aG "docker,nix-users" "$user"
echo "Created and assigned groups for $user!"

# ssh/gpg
echo "YOU NEED TO DO SOME THINGS NOW:"
echo "Create your *personal* ssh key"
ssh-keygen -t rsa -b 4096 -C "jules@wiriath.com"
printf "Which name did you give the key (~/.ssh/{name}) ? "
read -r personal_ssh_key

printf "Create your *professional* ssh key\nWhich email will this use ?\n"
read -r email_pro
ssh-keygen -t rsa -b 4096 -C "$email_pro"
read -r professional_ssh_key

echo "Create your *personal* gpg key"
gpg --full-generate-key

# gpg to git config (ssh should be automagically correct with the .ssh/config)
gpg_pro_key=$(gpg --list-key "Jules Wiriath <$email_pro>" | head -n 2 | tail -n 1 | cut -d ' ' -f 7)
gpg_perso_key=$(gpg --list-key "Jules Wiriath <jules@wiriath.com>" | head -n 2 | tail -n 1 | cut -d ' ' -f 7)
sed -i "s/signingkey = \(.*\)/signingkey = $gpg_pro_key/g" "$config/gitcfg/hexaglobe"
sed -i "s/signingkey = \(.*\)/signingkey = $gpg_perso_key/g" "$config/gitcfg/perso"

cleanup

echo "Some of the things we did require full system resync and upgrade."
doas pacman -Syyu

echo "You are very much advised to reboot your komputer."

