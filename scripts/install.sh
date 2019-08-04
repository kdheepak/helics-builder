#!/usr/bin/env bash

set -ev

CURRENT_DIR=`pwd`

mkdir -p "$HOME/helics"

wget https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.gz
tar -xzf boost_1_69_0.tar.gz

# cd boost_1_69_0 fails on osx travis
set +e
cd boost_1_69_0
set -e

if [[ "$TRAVIS_OS_NAME" == "windows" ]]; then
    ./bootstrap.bat --prefix=$HOME/helics/
else
    ./bootstrap.sh --prefix=$HOME/helics/
fi

if [[ "$TRAVIS_OS_NAME" == "windows" ]]; then
    while sleep 540; do echo "=====[ $SECONDS seconds still running ]====="; done &
    ./b2 -j2 toolset=msvc-14.0 address-model=$PYTHON_ARCH --layout=system --with-program_options --with-filesystem --with-system --with-test install > /dev/null 2>&1
    kill %1
else
    # Output something every 10 minutes or Travis kills the job
    while sleep 540; do echo "=====[ $SECONDS seconds still running ]====="; done &
    ./b2 -j4 link=shared --with-program_options --with-filesystem --with-system --with-test install > /dev/null 2>&1
    # Killing background sleep loop
    kill %1
fi

set +e
cd ..
set -e

curl -sSOL https://github.com/zeromq/libzmq/releases/download/v4.2.0/zeromq-4.2.0.tar.gz
tar zxf zeromq-4.2.0.tar.gz
set +e
cd zeromq-4.2.0
set -e

if [[ $TRAVIS_OS_NAME == "windows" ]]; then
    mkdir -p build
    set +e
    cd build
    set -e
    cmake -DCMAKE_INSTALL_PREFIX="$HOME/helics" ..
    cmake --build . --config Release --target install
else
    ./autogen.sh
    ./configure --prefix="$HOME/helics"
    make -j4
    make install
fi
set +e
cd ..
cd ..
set -e

wget https://github.com/GMLC-TDC/HELICS-src/archive/v$HELICS_VERSION.tar.gz
tar -xzf v$HELICS_VERSION.tar.gz
ls
set +e
cd HELICS-$HELICS_VERSION
set -e
mkdir -p build
set +e
cd build
set -e

if [[ $TRAVIS_OS_NAME == "windows" ]]; then
    cmake -DBOOST_ROOT="$HOME/helics" -DZeroMQ_ROOT_DIR="$HOME/helics" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/helics" -DBoost_USE_STATIC_LIBS=ON -G"Visual Studio 15 2017 Win64" -GNinja -DENABLE_PACKAGE_BUILD=ON -DBUILD_RELEASE_ONLY=ON -DBUILD_C_SHARED_LIB=ON -DBUILD_SHARED_LIBS=ON -DBUILD_PYTHON_INTERFACE=ON -DENABLE_SWIG=OFF ..
    cmake --build . --config Release --target install
else
    cmake -DBOOST_ROOT="$HOME/helics" -DZeroMQ_ROOT_DIR="$HOME/helics" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/helics" -DENABLE_PACKAGE_BUILD=ON -DBUILD_RELEASE_ONLY=ON -DBUILD_C_SHARED_LIB=ON -DBUILD_SHARED_LIBS=ON -DBUILD_PYTHON_INTERFACE=ON -DENABLE_SWIG=OFF ..
    make -j4
    make install
fi
set +e
cd ../../
cd $CURRENT_DIR
set -e

