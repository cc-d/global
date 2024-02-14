#!/bin/sh
[ "$(id -u)" -ne 0 ] && echo "Run as root" >&2 && exit 1
apt-get update -yq && apt-get upgrade -yq
apt-get install -yq software-properties-common git
cd $HOME; git clone https://github.com/cc-d/global.git
apt-get install -yq build-essential curl git libssl-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget llvm libncurses5-dev libncursesw5-dev xz-utils \
tk-dev libffi-dev liblzma-dev autoconf automake libtool nasm make pkg-config \
libghc-zlib-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip libz-dev libpq-dev openssl
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
echo 'export NVM_DIR="$HOME/.nvm"' >> $HOME/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> $HOME/.bashrc
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> $HOME/.bashrc
echo 'eval "$(pyenv init --path)"' >> $HOME/.bashrc
git clone https://github.com/cc-d/global.git $HOME/global
echo '. ~/global/init-globalshell.sh' >> $HOME/.bashrc

