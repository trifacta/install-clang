FROM trifacta/centos-clang:3.6
MAINTAINER Trifacta, Inc.

RUN yum -y groupinstall "Development Tools"
RUN yum -y install tar xz ruby-devel ruby rubygems
RUN gem install fpm

WORKDIR /target
CMD ["fpm", "-s", "dir", "-t", "rpm", "-n", "clang", \
    "-d", "glibc-devel", \
    "-d", "gcc", \
    "-p", "/target/clang-3.6.0-1.x86_64.rpm", \
    "-v", "3.6.0", "-C", "/target", "/opt/llvm36"]

VOLUME ["/target"]

# Instructions for creating a CentOS 6 clang rpm (from an image containing clang/llvm 
# under /opt/llvm36):
#   $ docker run --rm -v `pwd`:/target trifacta/clang-rpm-builder
# You should now have a clang-3.6.0.el6.x86-64.rpm file generated