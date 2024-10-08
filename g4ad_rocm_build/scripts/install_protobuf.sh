#!/bin/bash

set -ex

pb_dir="/usr/temp_pb_install_dir"
mkdir -p $pb_dir

curl -LO "https://github.com/protocolbuffers/protobuf/releases/download/v3.17.3/protobuf-all-3.17.3.tar.gz" --retry 3

tar -xvz --no-same-owner -C "$pb_dir" --strip-components 1 -f protobuf-all-3.17.3.tar.gz
NPROC=$[$(nproc) - 2]
pushd "$pb_dir" && ./configure && make -j${NPROC} && make -j${NPROC} check && sudo make -j${NRPOC} install && sudo ldconfig
popd
rm -rf $pb_dir
