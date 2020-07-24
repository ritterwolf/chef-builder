#!/bin/bash

#  Copyright 2019 Lyle Dietz
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

set -e

INSTALL_RUBY=2.6.5

# Install the build requirements.
# We check the commands available to decide what to install and how

if command -v dpkg; then # Debian derivative
  if [ -n "$MIRROR" ]; then
    sed -i -e "s|http://archive.ubuntu.com/ubuntu/|http://$MIRROR.archive.ubuntu.com/ubuntu/|" /etc/apt/sources.list
  fi

  export DEBIAN_FRONTEND=noninteractive

  apt update
  apt install -y lsb-release autoconf build-essential git wget zip libreadline-dev zlib1g-dev libxml2-dev libxslt1-dev pkg-config

  # Need to fill this out with Debian code names as well.
  case $(lsb_release -cs) in
    focal)
      apt install -u libssl-dev
      ;;
    *)
      apt install -u libssl1.0-dev
  esac

elif command -v dnf; then # Fedora
  dnf update -y
  dnf install -y autoconf gcc gcc-c++ make patch git \
    wget zip openssl-devel readline-devel zlib-devel libxslt-devel pkgconf-pkg-config \
    bzip2 rpm-build
elif command -v yum; then # RHEL/Centos/Old Fedora
  yum install -y autoconf gcc gcc-c++ make patch git \
    wget zip openssl-devel readline-devel zlib-devel libxslt-devel pkgconf-pkg-config \
    bzip2 rpm-build
else
  # Obviously I want to add more, but this is a start.
  echo "Unknown distribution, exiting"
  exit 2
fi

# Install rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src

# We only really need this for the current session
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Install ruby-build as an rbenv plugin
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

rbenv install "${INSTALL_RUBY}"

cd /src

rbenv local "${INSTALL_RUBY}"
gem install bundler

tar xfa /mnt/src/"$1"-"$2".tar.gz

cd "$1-$2"

# We don't have to accept the Chef EULA, and shouldn't need to, so overwrite it with the Apache License text.
find -name CHEF-EULA.md -exec cp LICENSE {} \;

if [ $(ls /mnt/patches/*.patch | wc -l) -gt 0 ]; then
  for i in /mnt/patches/*.patch; do
    patch -p1 < $i
  done
fi

cd omnibus

bundle install --without development
bundle exec omnibus build "$1"

cp pkg/* /mnt/pkg/
