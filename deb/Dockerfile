FROM trifacta/clang-builder:3.6-ubuntu1404
MAINTAINER Trifacta Inc.

RUN apt-get -y update && \
    apt-get -y install build-essential ruby-dev
RUN gem install fpm

VOLUME ["/target"]

WORKDIR /target
CMD ["fpm", "-s", "dir", "-t", "deb", "-n", "llvm-all", "-v", "3.6.1", \
      "-C", "/", \
      "--depends", "libatomic1", \
      "--license", "NCSA", \
      # Update the iteration when you update the build for the same package version
      "--iteration", "1", \
      "opt/llvm36"]
