FROM trifacta/centos-clang:3.4
MAINTAINER Trifacta, Inc.

ENV PARALLEL=10

WORKDIR /opt/downloads

RUN yum install -y centos-release-SCL
RUN yum install -y python27

# get some basic packages needed by the install
RUN yum install -y emacs wget tar xz

# Download llvm 3.6 release packages
RUN wget http://llvm.org/releases/3.6.0/llvm-3.6.0.src.tar.xz
RUN wget http://llvm.org/releases/3.6.0/cfe-3.6.0.src.tar.xz
RUN wget http://llvm.org/releases/3.6.0/compiler-rt-3.6.0.src.tar.xz
RUN wget http://llvm.org/releases/3.6.0/libcxx-3.6.0.src.tar.xz
RUN wget http://llvm.org/releases/3.6.0/libcxxabi-3.6.0.src.tar.xz
RUN wget http://llvm.org/releases/3.6.0/clang-tools-extra-3.6.0.src.tar.xz

### Copy and untar all the packages
WORKDIR /opt/llvm-src
RUN tar xf /opt/downloads/llvm-3.6.0.src.tar.xz
RUN mv llvm-3.6.0.src llvm

WORKDIR /opt/llvm-src/llvm/tools
RUN tar xf /opt/downloads/cfe-3.6.0.src.tar.xz
RUN mv cfe-3.6.0.src clang

WORKDIR /opt/llvm-src/llvm/projects
RUN tar xf /opt/downloads/compiler-rt-3.6.0.src.tar.xz
RUN mv compiler-rt-3.6.0.src/ compiler-rt

WORKDIR /opt/llvm-src/llvm/tools/clang/tools
RUN tar xf /opt/downloads/clang-tools-extra-3.6.0.src.tar.xz
RUN mv clang-tools-extra-3.6.0.src extra

WORKDIR /opt/llvm-src/llvm/projects
RUN tar xf /opt/downloads/libcxx-3.6.0.src.tar.xz
RUN mv libcxx-3.6.0.src/ libcxx

WORKDIR /opt/llvm-src/llvm/projects
RUN tar xf /opt/downloads/libcxxabi-3.6.0.src.tar.xz
RUN mv libcxxabi-3.6.0.src/ libcxxabi

WORKDIR /opt/llvm-build
RUN scl enable python27 "cmake -DLLVM_ENABLE_LIBCXX=on -DCMAKE_INSTALL_PREFIX=/opt/llvm36 -Wno-dev --enable-optimized --enable-cxx11 --with-libcxxabi -DCMAKE_BUILD_TYPE=Release -DLLVM_REQUIRES_RTTI=1 /opt/llvm-src/llvm/"

# Build just CXX first
RUN scl enable python27 "make -j$PARALLEL cxx"

# Build the rest of LLVM/Clang
RUN scl enable python27 "make -j$PARALLEL"

# install to /opt/llvm36
RUN scl enable python27 "make install"

RUN rm -rf /opt/llvm-build
RUN rm -rf /opt/llvm-src


# now we need to rebuild libcxxabi with a static version

WORKDIR /opt/libcxx-work
RUN tar xf /opt/downloads/libcxx-3.6.0.src.tar.xz
RUN mv libcxx-3.6.0.src/ libcxx

RUN tar xf /opt/downloads/libcxxabi-3.6.0.src.tar.xz
RUN mv libcxxabi-3.6.0.src/ libcxxabi

WORKDIR /opt/libcxx-work/build-libcxx-1


RUN scl enable python27 "cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_COMPILER=/opt/llvm36/bin/clang \
    -DCMAKE_CXX_COMPILER=/opt/llvm36/bin/clang++ \
    -DLIBCXX_LIBDIR_SUFFIX=64 \
    /opt/libcxx-work/libcxx"

RUN scl enable python27 "make -j$PARALLEL"
RUN scl enable python27 "make install"


# for some reason we have old libc++ in /usr/lib and this interferes
# with the build. So remove them for now. (TODO understand why)
RUN rm -f /usr/lib/libc++.so*

ENV PATH /opt/llvm36/bin:$PATH

# build libcxxabi using libc++ that we installed
WORKDIR /opt/libcxx-work/build-libcxxabi

RUN echo $PATH && scl enable python27 "LDFLAGS=\"-lc++abi\" cmake \
    -DLLVM_ENABLE_LIBCXX=On \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_COMPILER=/opt/llvm36/bin/clang \
    -DCMAKE_CXX_COMPILER=/opt/llvm36/bin/clang++ \
    -DLIBCXXABI_LIBCXX_INCLUDES=../libcxx/include \
    -DLIBCXXABI_ENABLE_SHARED=Off \
    -DLIBCXXABI_LIBDIR_SUFFIX=64 \
    /opt/libcxx-work/libcxxabi"

RUN scl enable python27 "make -j$PARALLEL"
RUN scl enable python27 "make install"

WORKDIR /opt/libcxx-work/build-libcxx-2

RUN scl enable python27 "cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_COMPILER=/opt/llvm36/bin/clang \
    -DCMAKE_CXX_COMPILER=/opt/llvm36/bin/clang++ \
    -DLIBCXX_ENABLE_SHARED=Off \
    -DLIBCXX_LIBDIR_SUFFIX=64 \
    -DLIBCXX_CXX_ABI_LIBRARY_PATH=/opt/libcxx-work/build-libcxx-2/lib64 \
    -DLIBCXX_CXX_ABI=libcxxabi\
    -DLIBCXX_LIBCXXABI_INCLUDE_PATHS=/opt/libcxx-work/libcxxabi/include \
    /opt/libcxx-work/libcxx"

RUN scl enable python27 "make -j$PARALLEL"
RUN scl enable python27 "make install"

WORKDIR /opt/libcxx-work/build-libcxx-3
# Dynamic version of the above
RUN scl enable python27 "cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_COMPILER=/opt/llvm36/bin/clang \
    -DCMAKE_CXX_COMPILER=/opt/llvm36/bin/clang++ \
    -DLIBCXX_ENABLE_SHARED=on \
    -DLIBCXX_LIBDIR_SUFFIX=64 \
    -DLIBCXX_CXX_ABI_LIBRARY_PATH=/opt/libcxx-work/build-libcxx-2/lib64 \
    -DLIBCXX_CXX_ABI=libcxxabi\
    -DLIBCXX_LIBCXXABI_INCLUDE_PATHS=/opt/libcxx-work/libcxxabi/include \
    /opt/libcxx-work/libcxx"

RUN scl enable python27 "make -j$PARALLEL"
RUN scl enable python27 "make install"

RUN rm -rf /opt/downloads
RUN rm -rf /opt/libcxx-work/ubuntu