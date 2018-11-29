[Archlinux on Vagrant 日本語/GUI/docker セットアップスクリプト](https://qiita.com/u1and0/items/26be6344ced826ee4868)

![image.png](https://qiita-image-store.s3.amazonaws.com/0/113494/a7f02a20-2ded-798a-ea7c-3d3e35522a5b.png)


# はよ
* [Vagrant Cloud / u1and0/archlinux](https://app.vagrantup.com/u1and0/boxes/archlinux)

```Shell-session
$ vagrant init u1and0/archlinux --box-version 1.0.0
$ vagrant up
``` 

Archlinux for Japanese

* ベースはterrywang/archlinux
* pacmanの強化
    * reflector: 近くのサーバーを/etc/pacman.d/mirrorlistに登録
    * powerpill: pacman のラッパー。aria2cとか使って高速ダウンロード
* GUI環境: xfce4
* dockerをsudoなしで実行できる
* the fuck: Corrects your previous console command
* atool: Managing file archives of various types
* vimpager: Syntax color highlighting pager
* man-page-ja-git: 日本語man
* gitflow-avh-git: git-flow tools
* /etc/boostrapedを見るとterrywang/archlinuxのboxに対して実行したこと(provisioning)がわかります。


# まえがき
[VirtualBox 用 Ubuntu 16.04 LTS "Xenial Xerus" 日本語デスクトップ イメージ](https://qiita.com/yuki-takei/items/056e1184680f572d4c3d)のArchlinux版みたいなのが欲しくて作りました。
イメージ作成はせずに既存のOSイメージ上でshellスクリプトで書いたプロビジョニングを走らせて日本語化・GUI化・dockerの設定行っております。
> dockerの設定は`docker info`と打ってデーモンが動いていることを確認できるまでを指しています。
> それ以降のdockerイメージを使ってなんちゃらはこの記事の範囲外です。

`bootstrap.sh`を書き換えることである程度のカスタマイズが可能です。いらない部分はコメントアウトし、個人的に必要だと思った部分は適宜書き加えて使用してください。

~~特に、"bootstrap.sh"の最後の方では[私のdotfiles](https://github.com/u1and0/dotfiles.git)をクローンしてくるので、その点はご自分のdotfilesリポジトリに書き換えることをお勧めします。しかしながらdotfilesの使用、書換を禁じているわけではありませんので、"bootstrap.sh"をそのまま使っていただいてもかまいません。~~
> dotfilesは自動的にcloneしないようにしました。

また、shellscriptを追っていけば単純に「Archlinuxことはじめ」としても使えると思います。(ネットワーク設定とか細かいことはterrywangさんが既にカスタマイズしてくれている模様)


## 誰向けの記事か

* 気軽に組み立て、気軽に試せて、気軽にぶっ壊せて、気軽に再立ち上げできる環境が欲しい
* vagrant, VirtualBoxの導入・使い方は普通にわかる
* Archlinuxに興味があるけど、怖くて手が出せない
* ArchlinuxをはじめLinuxOSで日本語化を一からやる方法がわからない
* MSYS2のpacmanじゃやれること狭すぎるよ
* pacman高速化したい
* vagrantで組み立てる日本語イメージが欲しい
* デスクトップ環境なんかいならくてCLIのみで軽量スマートに活用してﾄﾞﾔしたい日もあれば、デスクトップ環境をゴリゴリに改造してﾄﾞﾔしたい日もある
* 融通の利かないｵﾚｵﾚイメージの配布はやめろ


## 必要なもの・試した環境
* [vagrant](https://www.vagrantup.com/downloads.html)1.9.5
* [VirtualBox](https://www.vagrantup.com/downloads.html)5.1.22
* vagrantで立ち上げるarchlinuxのOSイメージ[terrywang/archlinux](https://app.vagrantup.com/terrywang/boxes/archlinux)

OSはwindows10 64bitで試しました。vagrantとVirtualBoxは常に最新版同士を使うことが良いとは限らないようで、私はこの組み合わせでうまくいきました。両者とも最新版は出ているのに1年くらい更新していません…。(試すのが面倒なだけです)

terrywang/archlinuxは更新頻度が高く、ダウンロード数も多く比較的信頼できるArchlinuxイメージだと思います。(自己責任でダウンロードしてください)
~~イメージファイルは`vagrant box add terrywang/archlinux`または`vagrant init terrywang/archlinux`で取得できます。~~


# [Archlinux](https://wiki.archlinux.jp/index.php/Arch_Linux)

  Arch Linux は、x86_64 向けに独自に開発された、あらゆる用途に対応できる万能 GNU/Linux ディストリビューションです。その開発は、シンプリシティ、ミニマリズム、およびコードの簡潔性に焦点を当てています。Arch は最小限の基本システムの状態でインストールされ、ユーザー自身が、ユーザーの理想とする環境のために必要なものだけをインストールして構築することができます。GUI の構成設定ツールは公式には提供されず、ほとんどのシステム設定はシェル上でテキストファイルを編集することで行います。Arch はローリングリリースモデルをベースとしており、常に最先端であるように努め、ほとんどのソフトウェアは最新の安定バージョンが提供されます。(Archlinux wikiより)


シンプル、ミニマル、汎用的、根っこから自分色に染める、do-it-yourselfの精神で自分ための自分だけの環境を作る。それがArchlinux...

それゆえに、難しい。挫折もある。大きな間違いを犯せば今までかけた環境構築の苦労の時間は水の泡。
そんな心配、仮想環境がなんとかしてくれるはず。

[Vagrant Cloud](https://app.vagrantup.com/boxes/search)には数多くの構築済みの環境がそろい、vagrantによる強力なprovisioningが環境構築を自動化してくれる。間違って大変なものを消してしまってもVirtualBoxによる強力なsnapshot機能が逃げ道をいつでも確保しておいてくれる。Archlinuxを試してみない理由はない...！

* [Arch Linuxとパッケージシステム](https://qiita.com/boronology/items/6ea8a4dd540c5980627b)←Archlinuxいいな、と思わされた記事
* [サーバOSとしてのArch Linux](http://3100.github.io/blog/2014/04/26/arch-linux-as-server-os.html)←Archlinuxが選ばれない理由8を多角的に分析した記事。Archlinuxのリスクについて知っておきたい人向け。




# 使い方
~~`https://github.com/u1and0/MyVagrant.gitからgit clone`でインストールしてください。イメージファイル以外に必要なファイルは次の二つです。~~

* ~~`Vagrantfile`~~
* ~~`bootstrap.sh`~~

`vagrant init u1and0/archlinux --box-version 1.0.0` や`vagrant box add `vagrant box add https://app.vagrantup.com/u1and0/boxes/archlinux`などでboxをダウンロードし、Vagrantfileを適宜書き換えて下さい。


# Vagrantfile
Vagrantfileの構成で必要最低限は以下の~~3~~2点

1. ~~`bootstrap.sh実行`の指示~~
2. GUI(=デスクトップ)環境設定
3. Windowの方など、ファイルシステムがNTFSなら`config.ssh.insert_key=false`

以下、最低限のVagrantfile

```ruby:Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  config.vm.box = "u1and0/archlinux"
  config.vm.box_version = "1.0.0"

  # GUI起動
  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    # クリップボードの共有: 双方向
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
  end
  GUI=true
  if GUI
    config.vm.provider "virtualbox" do |gui|
      # Display the VirtualBox GUI when booting the machine
      gui.gui = true
      gui.customize ["modifyvm", :id, "--ioapic", "on"]
      gui.customize ["modifyvm", :id, "--vram", "128"]
      gui.customize ["modifyvm", :id, "--accelerate3d", "on"]
    end
  end

  # NTFS環境
  config.ssh.insert_key=false  # root user ssh for sharing with windows machine
end
```


* [stack overflow - Private key to connect to the machine via SSH must be owned by the user running Vagrant](https://stackoverflow.com/questions/35964050/private-key-to-connect-to-the-machine-via-ssh-must-be-owned-by-the-user-running)



















# bootstrap.sh
[terrywang/archlinux](https://app.vagrantup.com/terrywang/boxes/archlinux)に対して追加したプロビジョニングです。
GUI設定や日本語manの追加や日本時間の設定など。


## /etc/bootstrappedというファイルがあれば終了
```bash:/etc/bootstrappedというファイルがあれば終了
test -f /etc/bootstrapped && exit
```

プロビジョニングの時点で`/etc/boostrapped`というファイルがあれば、プロビジョニングをせずに普通にVirtualBoxを起動します。
`/etc/boostrapped`は`bootstrap.sh`が終了したら書き込まれます。


## 日本語環境の構築

```bash
sudo timedatectl set-timezone Asia/Tokyo  # タイムゾーン設定
sudo cat << 'EOF' | sudo tee /etc/locale.conf
LANG=ja_JP.UTF8
LC_NUMERIC=ja_JP.UTF8
LC_TIME=ja_JP.UTF8
LC_MONETARY=ja_JP.UTF8
LC_PAPER=ja_JP.UTF8
LC_MEASUREMENT=ja_JP.UTF8
EOF
sudo mv /etc/locale.gen{,.bac}  # /etc/locale.genを/etc/locale.gen.bacにリネームする
echo ja_JP.UTF-8 UTF-8 | sudo tee /etc/locale.gen
sudo locale-gen
sudo pacman -Syy
```


```bash
sudo cat << 'EOF' | sudo tee なんかのファイル
なんとか
かんとか
EOF
```


```bash
echo 文字列 | sudo tee なんかのファイル
```

`sudo >(リダイレクト)`のような書き方が出来ないので代わりに`sudo tee` を挟むことで書き込みにroot権限が必要なファイルへのリダイレクトを行います。

teeはリダイレクトを行いながら標準出力にも吐き出すコマンドです。

ターミナル上で手動でやるならば`sudo vi`して該当箇所を変更すればいいのですが、自動化するにはひと工夫必要でした。これ以降何回も使っていきます。


# Remove libxfont for pacman datebase error
2018年2月頃から発生しているアップデート時のエラーです。
対処法は以下を参考にして`libxfont`を削除して、全パッケージを再度アップデートすることです。

[xorgprotoへのアップデートで、error: failed to prepare transaction (could not satisfy dependencies)のエラー](http://archlinux-blogger.blogspot.jp/2018/02/xorgprotoerror-failed-to-prepare.html)

```bash:libxfontの削除
sudo pacman -Rdd --noconfirm libxfont
sudo pacman -Syu --noconfirm
```

# pacman強化
## powerpillインストール

```bash:powerpillインストール
gpg --recv-keys 1D1F0DC78F173680
yaourt -S --noconfirm powerpill  # Use powerpill instead of pacman. Bye pacman...
```

[powerpill](https://wiki.archlinux.jp/index.php/Powerpill)はパッケージマネージャーpacmanのラッパーツールです。aria2cやreflectorを駆使してパッケージの高速ダウンロードを行ってくれます。AURからインストール必要があるほか、インストールに癖がありpgp鍵が必要です、 参考↓

* [Package Details: python3-xcgf 2017.3-1 ](https://aur.archlinux.org/packages/python3-xcgf/?comments=all)
* [Package Details: powerpill 2017.11-1](https://aur.archlinux.org/packages/powerpill/)




### powerpill SigLevel書き換え

```bash:SigLevel書換
sudo sed -ie 's/Required DatabaseOptional/PackageRequired/' /etc/pacman.conf
```

`/etc/pacman.conf`というファイルの`Required DatabaseOptional`を`PackageRequired`に書き換えないと、ダウンロード時にエラーが表示されます。

~~ここでも`sed`からのパイプで権限のあるファイルへのリダイレクトに`sudo tee`を使います。~~


* [Powerpill](https://wiki.archlinux.jp/index.php/Powerpill)





## mirrorlist書き換え

```bash:mirrorlist書き換え
sudo pacman -Syu --noconfirm reflector
sudo cp /etc/pacman.d/mirrorlist{,.bac}
sudo reflector --verbose --country 'Japan' -l 10 --sort rate --save /etc/pacman.d/mirrorlist
```

最大10個の日本のミラーをダウンロード速度順にソートし、/etc/pacman.d/mirrorlist ファイルに上書きします。


* [pacmanの使い方 | Arch Linux, pacman, オプション, パッケージ管理](http://archlinux-blogger.blogspot.jp/2014/11/pacman-arch-linux-pacman.html)


## GUI環境

```bash:GUI環境
sudo pacman -S --noconfirm xorg-xinit lightdm-gtk-greeter
yes 'all' | sudo pacman -S --noconfirm xfce4 lightdm
sudo systemctl enable lightdm.service
# /etc/systemd/system/default.targetのリンクをmulti-user.targetからgraphical.targetに変える
sudo systemctl set-default graphical.target
```


以下のパッケージをインストール

* xorg-xinit
* xfce4
* lightdm
* lightdm-gtk-greeter

lightdmを自動実行にしてログイン
`sudo systemctl enable lightdm.service`

/etc/systemd/system/default.targetのリンクをmulti-user.targetからgraphical.targetに変える
`sudo systemctl set-default graphical.target`

デスクトップ環境は軽量さが売りのxfce4です。ｲﾏﾄﾞｷデスクトップ環境が良いという方はGnomeやUnityなど探してみてください。
bootstrap.shではGUI環境構築は疎かにしております。

* [ArchLinuxをVirtualBoxにインストールし､GUI環境を構築するまで](https://qiita.com/okash1n/items/8929a67a3cd7223fb90c)
* [VirtualBoxにArchLinuxをインストールする](https://qiita.com/tomi_sheep/items/ddd9c7b0f0f7c774a222)
* [Arch Linuxのデスクトップ環境(もりねずみー編)](http://morinezumiiii.hatenablog.com/entry/2014/03/30/175903)←Archlinux（に限った話ではないと思うが）のデスクトップ環境比較



### フォントとインプットメソッドのインストール
```bash:フォントとインプットメソッドのインストール
yaourt -S --noconfirm otf-takao  # Takaoフォントインストール
yes 'all' | sudo pacman -S --noconfirm fcitx-im fcitx-configtool fcitx-mozc

sudo cat << 'EOF' > ${HOME}/.xprofile
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=”@im=fcitx”
EOF
```

インプットメソッドのインストールと変数書換を行います。

* [Arch Linuxに日本語環境を構築する](http://note.kurodigi.com/post-0-19/)
* [VirtualBoxでArch Linuxのインストール練習](http://chroju89.hatenablog.jp/entry/2014/09/07/232727)9


### キーボードの設定

```bash:キーボードの設定
sudo localectl set-keymap jp106
```

日本語キーボードjp106に切り替え。
英語用キーボードが好きな方はコメントアウトしてください。

* [ArchLinuxで日本語配列にならない場合の対処法](http://blog.goo.ne.jp/ykariunai77/e/791055fa9781ec92b4fa47bbd4f998de)
* [コンソールでのキーボード設定](https://wiki.archlinux.jp/index.php/%E3%82%B3%E3%83%B3%E3%82%BD%E3%83%BC%E3%83%AB%E3%81%A7%E3%81%AE%E3%82%AD%E3%83%BC%E3%83%9C%E3%83%BC%E3%83%89%E8%A8%AD%E5%AE%9A)


### 自動ログイン
```bash:自動ログイン
sudo sed -ie 's/#autologin-user=/autologin-user=vagrant/' /etc/lightdm/lightdm.conf
sudo groupadd -r autologin
sudo gpasswd -a vagrant autologin
# ↑一回目のログインはユーザー名とパスワード(どちらもvagrnat)打たないといけない
```

これを設定することで次回以降のログインで認証がいらなくなります。


## dockerセットアップ
```bash:dockerセットアップ
sudo pacman -S --noconfirm docker  # dockerインストール
sudo systemctl enable docker  # ログイン時にデーモン実行
sudo groupadd docker  # sudoなしで使えるようにする設定
sudo gpasswd -a vagrant docker  # sudoなしで使えるようにする設定
sudo systemctl restart docker
```

Vagrantfileに書く
` config.vm.provision "docker"`と同義？だと思います。Archlinuxのイメージではできなかったので、`bootstrap.sh`の中で設定しました。

* [Archlinux で docker](http://ikubakumonai.hatenablog.jp/entry/2014/06/04/141725)
* [Docs » Docker Engine » インストール » Arch Linux](http://docs.docker.jp/engine/installation/linux/archlinux.html)


## その他好きなもの
```bash:その他好きなもの
sudo pacman -S --noconfirm thefuck atool vimpager
# the fuck: Corrects your previous console command
# atool: Managing file archives of various types
# vimpager: Syntax color highlighting pager

yaourt -S --noconfirm man-pages-ja-git gitflow-avh-git
# man-page-ja-git: 日本語man
# gitflow-avh-git: git-flow tools
```


* [Arch Linuxのmanコマンドを日本語化する方法](http://note.kurodigi.com/archlinux-man/)


## 全パッケージのアップデート
```bash:全パッケージのアップデート
sudo powerpill -Syu --noconfirm
yaourt -Syua --noconfirm
```

~~`yaourt`には`-Syu`に加えて`-a`オプションも必要らしいです。~~
~~本当は今までの`pacman -S`を`pacman -Syu`にするべきなのかもしれませんが、実行速度が遅くなりそうなので`-S`だけにしています。その分ここで足並みそろえてもらうために`-Syu`~~



## 再bootstrap防止用ファイルの作成

```bash:再bootstrap防止用ファイルの作成
cat $0 | sudo tee /etc/bootstrapped
```

プロビジョニングの最後に`/etc/bootstrapped`というファイルに実行した~~日付時刻~~プロビジョニングの内容を書きみます。

`bootstrap.sh`はイニシャルセットアップスクリプトなので、初回起動時のみ動いたらお役御免です。次回以降`vagrant up`したときに発動しないようにするには`bootstrap.sh`の最初に書いた「/etc/bootstrappedというファイルがあれば終了」と合わせて`bootstrap.sh`の動きを封じます。



## 再起動
```bash:再起動
sudo reboot
```

GUIサービスやdockerサービス有効化のため再起動。
GUIによる自動ログインを有効化するため、初回のみユーザー名(vagrant)とパスワード(vagrant)を手動入力してログイン。
GUIを立ち上げずssh接続のみで使うなら不要。

> このコマンドは怪しい
> たまにログインループに陥る
> lightdmのせい

`> vagrant destroy -f`してもう一度立ち上げ直せば正しく立ち上がるかも。
> 一度xfceでログインすれば次回からは自動でユーザー名vagrantとして立ち上がる。



# スクリーンショット
![Screenshot from 2018-04-01 09-52-17.png](https://qiita-image-store.s3.amazonaws.com/0/113494/81676c1b-ef87-284f-6f5b-c64c1f552159.png)
Who am I?

![Screenshot from 2018-04-01 09-47-21.png](https://qiita-image-store.s3.amazonaws.com/0/113494/3552f200-739a-be13-4a54-3b6c1a7f26ab.png)
【pacman高速化】powerpill使える

![Screenshot from 2018-04-01 09-50-14.png](https://qiita-image-store.s3.amazonaws.com/0/113494/c15b76a0-d3d3-e1c5-4532-8a1ea62e6092.png)
docker使える




# まとめ
既存のvagrantイメージファイル[terrywang/archlinux](https://app.vagrantup.com/terrywang/boxes/archlinux)と
[オリジナルのセットアップスクリプト](https://github.com/u1and0/MyVagrant)を使って日本語化・GUI化・docker使用可能なArchlinux環境を組み立てました。


# 追記v1.0.0
* [Vagrant Cloud](https://app.vagrantup.com/u1and0/boxes/archlinux)にboxファイルをアップしました。
* [xorgprotoとlibxfontによるパッケージアップデートの失敗](http://archlinux-blogger.blogspot.jp/2018/02/xorgprotoerror-failed-to-prepare.html)を回避しました。
* これからは`bootstrap.sh`によるビルドはやめて

```Shell-session
$ vagrant init u1and0/archlinux --box-version 1.0.0
$ vagrant up
```
