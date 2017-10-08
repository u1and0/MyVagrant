#!/bin/bash
# 起動時に一度だけ実行されるprovisioning

# Exit if already bootstrapped
test -f /etc/bootstrapped && exit

# =================実行したいスクリプト===================
# タイムゾーン設定
sudo timedatectl set-timezone Asia/Tokyo


# =================dotfilesのクローン===================
git clone -b arch https://github.com/u1and0/dotfiles.git
# クローンしたすべてのファイルをホームへ移動
cd ${HOME}/dotfiles 
for i in `ls -A`
do
    mv -f $i ${HOME}
done
cd ${HOME} && rmdir dotfiles


## =================mirrorlist書き換え===================
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bac
sudo cat << 'EOF' | sudo tee /etc/pacman.d/mirrorlist
##
## Arch Linux repository mirrorlist
## Filtered by mirror score from mirror status page
## Generated on 2017-10-08
##

## Japan
Server = https://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch
Server = https://jpn.mirror.pkgbuild.com/$repo/os/$arch
Server = http://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch
Server = http://ftp.tsukuba.wide.ad.jp/Linux/archlinux/$repo/os/$arch

# Main
Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
EOF


## =================locale generate===================
sudo mv /etc/locale.gen /etc/locale.gen.bac
echo ja_JP.UTF-8 UTF-8 | sudo tee /etc/locale.gen
sudo locale-gen
sudo pacman -Syy


# =================パッケージの更新===================
sudo pacman -Syu --noconfirm


## =================GUI環境===================
sudo pacman -S --noconfirm xorg-xinit
yes 'all' | sudo pacman -S --noconfirm xfce4
yes 'all' | sudo pacman -S --noconfirm lightdm
sudo pacman -S --noconfirm lightdm-gtk-greeter
sudo systemctl enable lightdm.service
# /etc/systemd/system/default.targetのリンクをmulti-user.targetからgraphical.targetに変える
sudo systemctl set-default graphical.target

## =================日本語環境の構築===================
sudo cat << 'EOF' | sudo tee /etc/locale.conf
LANG=ja_JP.UTF8
LC_NUMERIC=ja_JP.UTF8
LC_TIME=ja_JP.UTF8
LC_MONETARY=ja_JP.UTF8
LC_PAPER=ja_JP.UTF8
LC_MEASUREMENT=ja_JP.UTF8
EOF

### =================フォントとインプットメソッドのインストール===================
sudo pacman -S --noconfirm otf-ipafont
yes 'all' | sudo pacman -S --noconfirm fcitx-im fcitx-configtool fcitx-mozc

sudo cat << 'EOF' > ${HOME}/.xprofile
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=”@im=fcitx”
EOF

# =================キーボードの設定===================
sudo localectl set-keymap jp106


## =================自動ログイン===================
sudo cat /etc/lightdm/lightdm.conf |
    sudo sed -e 's/#autologin-user=/autologin-user=vagrant/' |
        sudo tee /etc/lightdm/lightdm.conf
sudo groupadd -r autologin
sudo gpasswd -a vagrant autologin
# ↑一回目のログインはユーザー名とパスワード(どちらもvagrnat)打たないといけない

# =================yaourtによるインストール===================
yaourt -Syua --noconfirm
yaourt -S --noconfirm man-pages-ja-git
yaourt -S --noconfirm peco


# =================全パッケージのアップデート===================
sudo pacman -Syu --noconfirm
yaourt -Syua --noconfirm

# =================ログインshellをzshに変更===================
sudo chsh vagrant -s /usr/bin/zsh


# ====================================
# 実行したときの時間書き込み
date | sudo tee /etc/bootstrapped
sudo reboot
