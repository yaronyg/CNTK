#!/usr/bin/env bash
#
# Copyright (c) Microsoft. All rights reserved.
#
# Licensed under the MIT license. See LICENSE.md file in the project root
# for full license information.
# ==============================================================================
#

# WARNING!!!! These are just notes. I haven't tried to make this work for real yet. But it's useful for
# copying down the commands so I can repeat them exactly.

# Stop on error, trace commands
set -e -x

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

xcode-select --install

# Install some useful tools
brew install git
brew install wget
brew install libzip

# We need to update macOS's bash because it doesn't support arrays
brew install bash bash-completion
sudo -l
echo "$(brew --prefix)/bin/bash" >> /etc/shells
exit
chsh -s $(brew --prefix)/bin/bash
echo "export PATH=/usr/local/bin:/usr/local/sbin:\$PATH" >> ~/.bashrc

# coreutils gives us greadlink
brew install coreutils

# Need LLVM with openMP support
brew install --with-toolchain llvm
export CC=/usr/local/opt/llvm/bin/clang
export CXX=/usr/local/opt/llvm/bin/clang++ 
export CXXFLAGS='-I/usr/local/opt/llvm/include -I/usr/local/opt/llvm/include/c++/v1/'
export CPPFLAGS='-I/usr/local/opt/llvm/include -I/usr/local/opt/llvm/include/c++/v1/'
export LDFLAGS='-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib'

# Enter directory the script is located in
cd "$( dirname "${BASH_SOURCE[0]}" )"

rm -rf LocalDependencies

mkdir LocalDependencies

cd LocalDependencies

# Install openMPI
wget https://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.3.tar.bz2
tar xf openmpi-1.10.3.tar.bz2
cd openmpi-1.10.3
# See https://github.com/open-mpi/ompi/issues/3246 for why --disable-vt
./configure --prefix=/usr/local/mpi --disable-vt 2>&1 | tee config.out
make -j $(sysctl -n hw.logicalcpu) 2>&1 | tee make.out
sudo make install 2>&1 | tee install.out
cd ..
echo "export PATH=/usr/local/mpi/bin:\$PATH" >> ~/.bashrc

# Protobuf
brew install autoconf
brew install automake
brew install libtool
git clone https://github.com/yaronyg/protobuf.git
cd protobuf
./autogen.sh
./configure CFLAGS=-fPIC CXXFLAGS=-fPIC --disable-shared --prefix=/usr/local/protobuf-3.1.0
make -j $(sysctl -n hw.logicalcpu)
sudo make install
cd ..

# Note that brew puts boost 
brew install --c++11 boost

# Set up CNTK
cd ..
git clone --recursive https://github.com/yaronyg/CNTK.git
git remote add remote https://github.com/Microsoft/CNTK.git

# Now go register and download Intel Math Kernel Library 2017 Update 2 (I couldn't find a dl link for 11.3 update 3)

# Create custom version of MKL
cd CNTK/Dependencies/CNTKCustomMKL
./build-macos.sh
sudo mkdir /usr/local/CNTKCustomMKL
sudo tar -xzf CNTKCustomMKL-macOS-3.tgz -C /usr/local/CNTKCustomMKL

cd ../..
mkdir -p build/release
cd build/release
../../configure --with-boost=/usr/local/Cellar/boost/1.63.0 --with-mkl --mpi=no 2>&1 | tee configure.out
make -j $(sysctl -n hw.logicalcpu) all 2>&1 | tee make.out