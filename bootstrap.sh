#!/bin/bash
# 起動時に一度だけ実行されるprovisioning

# Exit if already bootstrapped
test -f /etc/bootstrapped && exit

# =================実行したいスクリプト===================

# =================日本語環境の構築===================
sudo timedatectl set-timezone Asia/Tokyo  # タイムゾーン設定
sudo cat << 'EOF' | sudo tee /etc/locale.conf
LANG=ja_JP.UTF8
LC_NUMERIC=ja_JP.UTF8
LC_TIME=ja_JP.UTF8
LC_MONETARY=ja_JP.UTF8
LC_PAPER=ja_JP.UTF8
LC_MEASUREMENT=ja_JP.UTF8
EOF
sudo mv /etc/locale.gen /etc/locale.gen.bac
echo ja_JP.UTF-8 UTF-8 | sudo tee /etc/locale.gen
sudo locale-gen
sudo pacman -Syy



# =================pacman強化===================
## =================powerpillインストール===================
gpg --recv-keys --keyserver hkp://pgp.mit.edu 1D1F0DC78F173680
yaourt -S --noconfirm powerpill  # Use powerpill instead of pacman. Bye pacman...

### =================powerpill SigLevel書き換え===================
sudo cat /etc/pacman.conf |
    sudo sed -e 's/Required DatabaseOptional/PackageRequired/' |
        sudo tee /etc/pacman.conf


## =================mirrorlist書き換え===================
sudo pacman -S --noconfirm reflector
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bac
sudo reflector --verbose --country 'Japan' -l 10 --sort rate --save /etc/pacman.d/mirrorlist



# =================GUI環境===================
sudo pacman -S --noconfirm xorg-xinit lightdm-gtk-greeter
yes 'all' | sudo pacman -S --noconfirm xfce4 lightdm
sudo systemctl enable lightdm.service
# /etc/systemd/system/default.targetのリンクをmulti-user.targetからgraphical.targetに変える
sudo systemctl set-default graphical.target


## =================フォントとインプットメソッドのインストール===================
yaourt -S --noconfirm otf-takao
yes 'all' | sudo pacman -S --noconfirm fcitx-im fcitx-configtool fcitx-mozc

sudo cat << 'EOF' > ${HOME}/.xprofile
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=”@im=fcitx”
EOF

## =================キーボードの設定===================
sudo localectl set-keymap jp106


## =================自動ログイン===================
sudo cat /etc/lightdm/lightdm.conf |
    sudo sed -e 's/#autologin-user=/autologin-user=vagrant/' |
        sudo tee /etc/lightdm/lightdm.conf
sudo groupadd -r autologin
sudo gpasswd -a vagrant autologin
# ↑一回目のログインはユーザー名とパスワード(どちらもvagrnat)打たないといけない


# =====================dockerセットアップ==========================
sudo pacman -S --noconfirm docker  # dockerインストール
sudo systemctl enable docker  # ログイン時にデーモン実行
sudo groupadd docker  # sudoなしで使えるようにする設定
sudo gpasswd -a vagrant docker  # sudoなしで使えるようにする設定
sudo systemctl restart docker

# =================その他好きなもの===================
yaourt -S --noconfirm man-pages-ja-git  # 日本語man
sudo pacman -S --noconfirm fzf  # Simplistic interactive filtering tool
sudo pacman -S --noconfirm thefuck  # Corrects your previous console command
sudo pacman -S --noconfirm atool  # Managing file archives of various types
yaourt -S --noconfirm gitflow-avh-git  # git-flow tools


# =================全パッケージのアップデート===================
sudo powerpill -Syu --noconfirm
yaourt -Syua --noconfirm


# =================shell環境構築===================
## =================dotfilesのクローン===================
git clone --recursive --depth 1 https://github.com/u1and0/dotfiles.git
cd ${HOME}/dotfiles  # クローンしたすべてのファイルをホームへ移動
for i in `ls -A`
do
    mv -f $i ${HOME}
done
# `mv`の代わりに`cp`を使っても良いが、`cp *`だけだとドットファイル移動できないので、
# `cp .*`も使う必要あり。冗長的なので`ls -A`と`mv`で一回で移動できるようにしました。
cd ${HOME} && rmdir dotfiles


## =================ログインshellをzshに変更===================
sudo chsh vagrant -s /usr/bin/zsh


# ================End of bootstraping====================
# 実行したときの時間書き込み
date | sudo tee /etc/bootstrapped
sudo reboot
