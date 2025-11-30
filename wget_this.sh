#!/bin/sh

set -xeu

#
# # WARNING
#
# # This script has never been tested, not even ran once. I strongly advise
# # against using it or taking it as a base for something custom.
#
# # I'll delete this message on my next install when this script will have ran
# # successfully at least once.
#

user="$(whoami)"
# `path//to//file` are valid posix file paths, I'd rather double the slashes
# most of the time and everything still work when I forget one than breaking
# something for a small mistake
home="/home/$user/"
hsh="$home/hsh/"
config="$home/.config/"
ssh="$home/.ssh/"
dotfiles_rep="$hsh/workspace/perso/dotfiles"
tmpdir=$(mktemp -d)

install_bins() {
  doas pacman --noconfirm -S "$@"
}

# Add stuff here when you create artifacts. Use absolute path here since
# we have no guarantees where the user is.
safe_cleanup() {
  echo "Cleaning up..."

  doas rm -rf "$tmpdir"

  # Remove the no password option
  echo "permit persist $user as root" | doas tee /etc/doas.conf

  echo "Done cleaning!"
}

make_sym() {
  source="$1"
  dest="$2"
  
  [ -e "$dest" ] && rm -rf "$dest"

  ln -s "$source" "$dest"
}

#!/bin/bash

generate_gpg_key() {
    name="$1"
    email="$2"
    key_type="${3:-RSA}"
    key_length="${4:-4096}"
    expire_date="${5:-0}"

    gpg --batch --gen-key <<EOF
Key-Type: $key_type
Key-Length: $key_length
Subkey-Type: $key_type
Subkey-Length: $key_length
Name-Real: $name
Name-Email: $email
Expire-Date: $expire_date
%no-protection
%commit
EOF
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

  sudo pacman --noconfirm -S doas
  # During the script, we set nopass to not bother the user with a password
  # everytime. The `cleanup()` function should change that after the script has
  # run.
  echo "permit nopass $user as root" | sudo tee /etc/doas.conf
  # This is kinda dirty, but it's written in the archwiki so ima trust
  # it
  # FIXME doesn't really work, paru can be configured to use someting else, but
  # makepkg seems to use sudo options doas don't have. ig I'll just keep boths.
  # doas rm /usr/bin/sudo
  # doas ln -s "$(which doas)" /usr/bin/sudo
else
  echo "doas was already installed."
fi
echo "Finished installing doas!"

echo "Cloning dotfiles (no ssh, no recursive)..."
mkdir -p "$dotfiles_rep"
install_bins git
# TODO After the setup, change the remote to be ssh instead of http, and clone
# recursively for control_modules
git clone "https://github.com/Aaalibaba42/dotfiles.git" "$dotfiles_rep"
echo "Cloned dotfiles!"

# We want to have parralel Downloads before installing stuff required, so it's
# better to start by moving at least that part of the config
echo "Activating Parrallel Downloads"
doas cp "$dotfiles_rep/etc/pacman.conf" /etc/pacman.conf
echo "Parrellel Downloads activated!"

echo "Setting up chaotic AUR..."
doas pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
doas pacman-key --lsign-key 3056513887B78AEB

doas pacman --noconfirm -U \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
doas pacman --noconfirm -U \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

printf "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" \
  | doas tee -a /etc/pacman.conf

doas pacman --noconfirm -Sy
echo "Finished setting up chaotic AUR!"

echo "Installing truckload of stuff..."
# I actually *need* word splitting here, the pacman.packages should not
# contain spaces.
install_bins $(tr '\n' ' ' < "$dotfiles_rep/pacman.packages")
echo "Finished installing truckload of stuff!"

echo "Installing Rust (required for paru)..."
rustup install stable nightly
echo "Finished installing Rust!"

echo "Installing paru..."
git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
makepkg -si -D "$tmpdir/paru/"
echo "Finished installing Paru!"

echo "Installing AUR packages"
# I actually *need* word splitting here, the paru.packages should not
# contain spaces.
paru --noconfirm -S $(tr '\n' ' ' < "$dotfiles_rep/paru.packages")
echo "Finished install of AUR packages!"

# config symlinks
make_sym "$dotfiles_rep/.gitconfig" "$home/.gitconfig"
make_sym "$dotfiles_rep/.config/gitcfg" "$config/gitcfg"
make_sym "$dotfiles_rep/.bashrc" "$home/.bashrc"
make_sym "$dotfiles_rep/.config/rofi" "$config/rofi"
make_sym "$dotfiles_rep/.config/waybar" "$config/waybar"
make_sym "$dotfiles_rep/.config/swaylock" "$config/swaylock"
make_sym "$dotfiles_rep/.config/kitty" "$config/kitty"
make_sym "$dotfiles_rep/.config/hypr" "$config/hypr"
make_sym "$dotfiles_rep/.config/helix" "$config/helix"
make_sym "$dotfiles_rep/hsh/wallpapers" "$hsh/wallpapers"
make_sym "$dotfiles_rep/.ssh/config" "$home/.ssh/config"

# TODO nix

# groups/user config
echo "Creating groups and attributing them to $user..."
doas groupadd nix-users
doas usermod -aG "docker,nix-users" "$user"
echo "Created and assigned groups for $user!"

# ssh/gpg
echo "Creating the ssh and gpg keys..."
printf "\e[41;35mYOU NEED TO DO SOME THINGS NOW:\e[0m"
echo "Create your *personal* ssh key"
ssh-keygen -t rsa -b 4096 -C "jules@wiriath.com"

printf "Create your *professional* ssh key\nWhich email will this use ?\n"
read -r email_pro
ssh-keygen -t rsa -b 4096 -C "$email_pro"

echo "Generating *personal* gpg key"
generate_gpg_key "Jules Wiriath" "jules@wiriath.com" 
echo "Generating *professional* gpg key"
generate_gpg_key "Jules Wiriath" "$email_pro"

# gpg to git config (ssh should be automagically correct with the .ssh/config)
gpg_pro_key=$(gpg --list-key "Jules Wiriath <$email_pro>" \
  | head -n 2 \
  | tail -n 1 \
  | cut -d ' ' -f 7)
gpg_perso_key=$(gpg --list-key "Jules Wiriath <jules@wiriath.com>" \
  | head -n 2 \
  | tail -n 1 \
  | cut -d ' ' -f 7)
echo "Adding gpg and mail to git configuration"
sed -i "s/signingkey = \(.*\)/signingkey = $gpg_pro_key/g" \
  "$config/gitcfg/pro"
sed -i "s/email = \(.*\)/email = $email_pro/g" \
  "$config/gitcfg/pro"
sed -i "s/signingkey = \(.*\)/signingkey = $gpg_perso_key/g" \
  "$config/gitcfg/perso"
echo "Created and setup the ssh and gpg keys!"

# decrypt personal vault
echo "Decrypting the personal vault..."
openssl enc -d -aes-256-cbc -in "$dotfiles_rep/hsh/perso.tar.gz.enc" \
  -out "$tmpdir/perso.tar.gz"
tar -xzf "$tmpdir/perso.tar.gz" -C "$hsh/perso/"
echo "Decrypted the personal vault!"

safe_cleanup

echo "Some of the things we did require full system resync and upgrade."
doas pacman --noconfirm -Syyu

echo "You are very much advised to reboot your komputer."

