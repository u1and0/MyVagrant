# terrywang/archlinux日本語セットアップスクリプト

## 起動時に一度だけ実行されるprovisioning
プロビジョニングの最初に`/etc/boostrapped`というファイルがあれば、プロビジョニングをせずに終了する。
`test -f /etc/bootstrapped && exit`

プロビジョニングの最後に`/etc/bootstrapped`というファイルに実行した日付を書き込む。
`date | sudo tee /etc/bootstrapped`


# タイムゾーン設定
タイムゾーンを日本に設定
`sudo timedatectl set-timezone Asia/Tokyo`


# dotfilesのクローン
`git clone -b arch https://github.com/u1and0/dotfiles.git`

クローンしたすべてのファイルをホームへ移動
```
cd ${HOME}/dotfiles 
for i in `ls -A`
do
    mv -f $i ${HOME}
done
cd ${HOME} && rmdir dotfiles
```


## mirrorlist書き換え
`/etc/pacman.d/mirrorlist`の内容を日本サーバーに書き換え

```
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
```


## locale generate
日本語用に設定し、pacmanリポジトリをアップデート

```
sudo mv /etc/locale.gen /etc/locale.gen.bac
echo ja_JP.UTF-8 UTF-8 | sudo tee /etc/locale.gen
sudo locale-gen
```
リポジトリアップデート
sudo pacman -Syy


# ここでひとまずパッケージの更新
`sudo pacman -Syu --noconfirm`


# GUI環境
以下のパッケージをインストール

* xorg-xinit
* xfce4
* lightdm
* lightdm-gtk-greeter

lightdmを自動実行にしてログイン
`sudo systemctl enable lightdm.service`

/etc/systemd/system/default.targetのリンクをmulti-user.targetからgraphical.targetに変える
`sudo systemctl set-default graphical.target`


## 日本語環境の構築
`/etc/locale.conf`に以下を書き込む。

```
LANG=ja_JP.UTF8
LC_NUMERIC=ja_JP.UTF8
LC_TIME=ja_JP.UTF8
LC_MONETARY=ja_JP.UTF8
LC_PAPER=ja_JP.UTF8
LC_MEASUREMENT=ja_JP.UTF8
```


### フォントとインプットメソッドのインストール
以下のパッケージをインストール

* otf-ipafont
* fcitx-im
* fcitx-configtool
* fcitx-mozc

.xprofileに以下を書き込む。
```
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=”@im=fcitx”
```



# キーボードの設定
日本語キーボードjp106に切り替え
`localectl set-keymap jp106`



## 自動ログイン
```
sudo cat /etc/lightdm/lightdm.conf |
    sudo sed -e 's/#autologin-user=/autologin-user=vagrant/' | sudo tee /etc/lightdm/lightdm.conf
sudo groupadd -r autologin
sudo gpasswd -a vagrant autologin
```

一回目のログインはユーザー名とパスワード(どちらもvagrnat)打たないといけない


# yaourtによるインストール
以下のパッケージを`yaourt -S <package>`でインストール
sudoはいらない

* man-pages-ja-git: 日本語マニュアル
* peco: 標準出力からあいまい検索


# 全パッケージのアップデート
```
sudo pacman -Syu --noconfirm
yaourt -Syua --noconfirm
```


# ログインshellをzshに変更
ユーザーvagrantのシェルを変える。

`sudo chsh vagrant -s /usr/bin/zsh`



# 再起動
GUIによる自動ログインを有効化するため、lightdmからxfceにログイン。

`sudo reboot`
このコマンドは怪しい
たまにログインループに陥る
lightdmのせい

`vagrant destroy -f`してもう一度立ち上げ直せば正しく立ち上がるかも。
一度xfceでログインすれば次回からは自動でvagrantとして立ち上がる。
