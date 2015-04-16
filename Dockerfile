
FROM        ubuntu:trusty
MAINTAINER  Trifacta Inc.

# Setup environment.
ENV PATH /opt/llvm/bin:$PATH

# Default command on startup.
CMD bash

# Setup packages.
RUN apt-get update && apt-get -y install cmake git build-essential vim python

# Copy install-clang over.
ADD . /opt/install-clang

# Compile and install LLVM/clang. We delete the source directory to
# avoid committing it to the image.
RUN bash /opt/install-clang/install-clang -j 40 /opt/llvm


