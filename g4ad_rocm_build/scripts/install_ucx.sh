#!/bin/bash

set -ex

git clone --recursive https://github.com/ROCm/ucx.git
pushd ucx
git checkout ${UCX_CHECKOUT_POINT}
git submodule update --init --recursive

./autogen.sh
./configure --prefix=/usr           \
    --enable-mt                     \
    --with-rocm=/opt/rocm           \
    --enable-profiling              \
    --enable-stats
time make -j
sudo make install

popd
rm -rf ucx