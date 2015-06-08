#!/bin/bash

set -e
set -x

function mkdirAndCd {
  mkdir -p $1
  cd $1
}

mkdirAndCd /opt/downloads

wget -q http://llvm.org/releases/3.6.1/llvm-3.6.1.src.tar.xz
wget -q http://llvm.org/releases/3.6.1/cfe-3.6.1.src.tar.xz
wget -q http://llvm.org/releases/3.6.1/compiler-rt-3.6.1.src.tar.xz
wget -q http://llvm.org/releases/3.6.1/libcxx-3.6.1.src.tar.xz
wget -q http://llvm.org/releases/3.6.1/libcxxabi-3.6.1.src.tar.xz
wget -q http://llvm.org/releases/3.6.1/clang-tools-extra-3.6.1.src.tar.xz
wget -q http://llvm.org/releases/3.6.1/lld-3.6.1.src.tar.xz
wget -q http://llvm.org/releases/3.6.1/lldb-3.6.1.src.tar.xz

### Copy and untar all the packages
mkdirAndCd /opt/llvm-src
tar xf /opt/downloads/llvm-3.6.1.src.tar.xz
mv  llvm-3.6.1.src llvm

mkdirAndCd /opt/llvm-src/llvm/tools
tar xf /opt/downloads/cfe-3.6.1.src.tar.xz
mv cfe-3.6.1.src clang

mkdirAndCd /opt/llvm-src/llvm/projects
tar xf /opt/downloads/compiler-rt-3.6.1.src.tar.xz
mv compiler-rt-3.6.1.src/ compiler-rt

mkdirAndCd /opt/llvm-src/llvm/tools/clang/tools
tar xf /opt/downloads/clang-tools-extra-3.6.1.src.tar.xz
mv clang-tools-extra-3.6.1.src extra

mkdirAndCd /opt/llvm-src/llvm/projects
tar xf /opt/downloads/libcxx-3.6.1.src.tar.xz
mv libcxx-3.6.1.src/ libcxx

mkdirAndCd /opt/llvm-src/llvm/projects
tar xf /opt/downloads/libcxxabi-3.6.1.src.tar.xz
mv libcxxabi-3.6.1.src/ libcxxabi

mkdirAndCd /opt/llvm-src/llvm/tools
tar xf /opt/downloads/lld-3.6.1.src.tar.xz
mv lld-3.6.1.src lld

## LLDB Does not work yet
#mkdirAndCd /opt/llvm-src/llvm/tools
#tar xf /opt/downloads/lldb-3.6.1.src.tar.xz
#mv lldb-3.6.1.src lldb

mkdirAndCd /opt/llvm-build
cmake \
    -DPYTHON_LIBRARY=/opt/rh/python27/root/usr/lib64/libpython2.7.so \
    -DPYTHON_INCLUDE_DIR=/opt/rh/python27/root/usr/include/python2.7/ \
    -DLLVM_ENABLE_LIBCXX=on \
    -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PREFIX} \
    -Wno-dev --enable-optimized \
    --enable-cxx11 \
    --with-libcxxabi \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_REQUIRES_RTTI=1 /opt/llvm-src/llvm/

# Build just CXX first
make -j${PARALLEL} cxx

# Build the rest of LLVM/Clang
make -j${PARALLEL}

# install to LLVM_INSTALL_PREFIX
make install

rm -rf /opt/llvm-build
rm -rf /opt/llvm-src

# now we need to rebuild libcxxabi with a static version
mkdirAndCd /opt/libcxx-work
tar xf /opt/downloads/libcxx-3.6.1.src.tar.xz
mv libcxx-3.6.1.src/ libcxx

tar xf /opt/downloads/libcxxabi-3.6.1.src.tar.xz
mv libcxxabi-3.6.1.src/ libcxxabi

mkdirAndCd /opt/libcxx-work/build-libcxx-1

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PREFIX} \
  -DCMAKE_C_COMPILER=${LLVM_INSTALL_PREFIX}/bin/clang \
  -DCMAKE_CXX_COMPILER=${LLVM_INSTALL_PREFIX}/bin/clang++ \
  /opt/libcxx-work/libcxx

make -j${PARALLEL}
make install

# for some reason we have old libc++ in /usr/lib and this interferes
# with the build. So remove them for now. (TODO understand why)
rm -f /usr/lib/libc++.so*

export PATH=${LLVM_INSTALL_PREFIX}/bin:$PATH

# build libcxxabi(static) using libc++ that we installed and
# install it in $LLVM_INSTALL_PREFIX
# the dynamic version is already built and installed by earlier steps
mkdirAndCd /opt/libcxx-work/build-libcxxabi

echo $PATH && cmake \
  -DLLVM_ENABLE_LIBCXX=On \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PREFIX} \
  -DCMAKE_C_COMPILER=${LLVM_INSTALL_PREFIX}/bin/clang \
  -DCMAKE_CXX_COMPILER=${LLVM_INSTALL_PREFIX}/bin/clang++ \
  -DLIBCXXABI_LIBCXX_INCLUDES=../libcxx/include \
  -DLIBCXXABI_ENABLE_SHARED=Off \
  /opt/libcxx-work/libcxxabi

make -j${PARALLEL}
make install

# we now compile a libc++(static) using the new libc++abi
# and install it in ${LLVM_INSTALL_PREFIX}
mkdirAndCd /opt/libcxx-work/build-libcxx-2

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PREFIX} \
  -DCMAKE_C_COMPILER=${LLVM_INSTALL_PREFIX}/bin/clang \
  -DCMAKE_CXX_COMPILER=${LLVM_INSTALL_PREFIX}/bin/clang++ \
  -DLIBCXX_ENABLE_SHARED=Off \
  -DLIBCXX_CXX_ABI_LIBRARY_PATH=/opt/libcxx-work/build-libcxx-2/lib \
  -DLIBCXX_CXX_ABI=libcxxabi\
  -DLIBCXX_LIBCXXABI_INCLUDE_PATHS=/opt/libcxx-work/libcxxabi/include \
  /opt/libcxx-work/libcxx

make -j${PARALLEL}
make install

# we now compile a libc++(dynamic) using the new libc++abi
# and install it in $LLVM_INSTALL_PREFIX
mkdirAndCd /opt/libcxx-work/build-libcxx-3
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PREFIX} \
  -DCMAKE_C_COMPILER=${LLVM_INSTALL_PREFIX}/bin/clang \
  -DCMAKE_CXX_COMPILER=${LLVM_INSTALL_PREFIX}/bin/clang++ \
  -DLIBCXX_ENABLE_SHARED=on \
  -DLIBCXX_CXX_ABI_LIBRARY_PATH=/opt/libcxx-work/build-libcxx-2/lib64 \
  -DLIBCXX_CXX_ABI=libcxxabi\
  -DLIBCXX_LIBCXXABI_INCLUDE_PATHS=/opt/libcxx-work/libcxxabi/include \
  /opt/libcxx-work/libcxx

make -j${PARALLEL}
make install

rm -rf /opt/downloads
rm -rf /opt/libcxx-work/ubuntu
