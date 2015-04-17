FROM trifacta/centos-python:2.7

RUN yum -y install epel-release
RUN yum -y groupinstall "Development Tools"
# EPEL repo has clang-3.4. We need cmake for compiling libcxx (the second time)
RUN yum -y install clang which cmake

# Instructions adapted from exposition at
# https://davidmnoriega.wordpress.com/2014/05/06/building-libc-on-centos-6-2/
# libcxxabi needs libcxx to compile, but libcxx needs to link against
# some c++ abi.
# We solve this problem by building & linking libcxx against libstdc++, using
# that to compile libcxxabi, then building & linking libcxx against libcxxabi.

ADD files/libcxx-3.6.0.src.tar.xz /opt/
RUN mv /opt/libcxx-3.6.0.src /opt/libcxx-1

ADD files/libcxxabi-3.6.0.src.tar.xz /opt/
RUN mv /opt/libcxxabi-3.6.0.src /opt/libcxxabi

RUN cp -r /opt/libcxx-1 /opt/libcxx-2

ENV CC clang
ENV CXX clang++

# First step, build libcxx against (old) libstdc++
WORKDIR /opt/libcxx-1/lib
RUN ./buildit
RUN cp libc++.so.1.0 /usr/lib64 && \
    ln -s libc++.so.1.0 /usr/lib64/libc++.so && \
    ln -s libc++.so.1.0 /usr/lib64/libc++.so.1 && \
    cp -r /opt/libcxx-1/include/ /usr/include/c++/v1

# Second step, build libcxxabi against the newly built libcxx
WORKDIR /opt/libcxxabi/lib
# Hack: Remove libstdc++ from the compiled output
RUN sed -i 's/-lc -lstdc++/-lc/' /opt/libcxxabi/lib/buildit
RUN ./buildit
RUN cp libc++abi.so.1.0 /usr/lib64/libc++abi.so.1.0 && \
    ln -s libc++abi.so.1.0 /usr/lib64/libc++abi.so && \
    ln -s libc++abi.so.1.0 /usr/lib64/libc++abi.so.1

# Third step, build libcxx again, now with libcxxabi
WORKDIR /opt/libcxx-2
# Patch libcxx compilation process so that we include all symbols from
# libcxxabi. See patch file for more details.
ADD files/projects--libcxx--libcxxabi-symbols.patch /tmp/patches/libcxx/
RUN patch -p1 </tmp/patches/libcxx/projects--libcxx--libcxxabi-symbols.patch
RUN mkdir build
WORKDIR build
RUN cmake \
  -DLIBCXX_CXX_ABI=libcxxabi \
  -DLIBCXX_LIBCXXABI_INCLUDE_PATHS=/opt/libcxxabi/include \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DLIBCXX_LIBDIR_SUFFIX=64 \
  -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
  -DLIBCXX_LIBCXXABI_WHOLE_ARCHIVE=ON \
  .. && \
  make VERBOSE=1 && \
  make install

# Test with libc++
WORKDIR /tmp
ADD files/test.cpp /tmp/test.cpp
RUN clang++ -stdlib=libc++ -std=c++11 -pthread test.cpp -o ./test
RUN ./test

WORKDIR /
