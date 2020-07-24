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

DISTRO=$1
DVERS=$2
PRODUCT=$3
RELEASE=$4

case "${PRODUCT}" in
  chef)
    GH_USER="chef"
    VERS_PREFIX="v"
    ;;
  chef-server)
    GH_USER="chef"
    VERS_PREFIX=""
    ;;
  chef-workstation)
    GH_USER="chef"
    VERS_PREFIX=""
    ;;
  inspec)
    GH_USER="inspec"
    VERS_PREFIX="v"
    ;;
esac

# Fetch the source file if we don't have it.
if [ ! -e src/"${PRODUCT}"-"${RELEASE}".tar.gz ]; then
  wget -O src/"${PRODUCT}"-"${RELEASE}".tar.gz https://github.com/"${GH_USER}"/"${PRODUCT}"/archive/"${VERS_PREFIX}""${RELEASE}".tar.gz
fi

docker run --rm \
  -v "$(pwd)"/src:/mnt/src:Z \
  -v "$(pwd)"/patches/$PRODUCT:/mnt/patches:Z \
  -v "$(pwd)"/pkg/"${DISTRO}"/"${DVERS}":/mnt/pkg:Z \
  -v "$(pwd)/mkpkg.sh":/usr/local/bin/mkpkg.sh:Z \
  --tmpfs /src:rw \
  -e MIRROR=$(< mirror.txt) \
  "${DISTRO}:${DVERS}" /usr/local/bin/mkpkg.sh "${PRODUCT}" "${RELEASE}"
