
FROM        ubuntu:trusty

MAINTAINER Trifacta Inc.

# Setup environment.

# Default command on startup.
CMD bash

RUN apt-get update && \
    apt-get -y install software-properties-common wget


RUN add-apt-repository -s -y 'deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.6 main' && \
    wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|apt-key add -

# Setup packages.
RUN apt-get update && \
    apt-get -y install cmake git build-essential \
            emacs24 vim python \
	    clang-3.6 clang-3.6-doc libclang-common-3.6-dev \
	    libclang-3.6-dev libclang1-3.6 libclang1-3.6-dbg \
	    libllvm3.6 libllvm3.6-dbg lldb-3.6 llvm-3.6 llvm-3.6-dev \
	    llvm-3.6-doc llvm-3.6-examples llvm-3.6-runtime \
	    clang-modernize-3.6 clang-format-3.6 python-clang-3.6 \
	    lldb-3.6-dev libc++-dev libc++abi-dev

RUN update-alternatives --install \
        /usr/bin/llvm-config       llvm-config      /usr/bin/llvm-config-3.6  200 \
	--slave /usr/bin/llvm-ar           llvm-ar          /usr/bin/llvm-ar-3.6 \
	--slave /usr/bin/llvm-as           llvm-as          /usr/bin/llvm-as-3.6 \
	--slave /usr/bin/llvm-bcanalyzer   llvm-bcanalyzer  /usr/bin/llvm-bcanalyzer-3.6 \
	--slave /usr/bin/llvm-cov          llvm-cov         /usr/bin/llvm-cov-3.6 \
	--slave /usr/bin/llvm-diff         llvm-diff        /usr/bin/llvm-diff-3.6 \
	--slave /usr/bin/llvm-dis          llvm-dis         /usr/bin/llvm-dis-3.6 \
	--slave /usr/bin/llvm-dwarfdump    llvm-dwarfdump   /usr/bin/llvm-dwarfdump-3.6 \
	--slave /usr/bin/llvm-extract      llvm-extract     /usr/bin/llvm-extract-3.6 \
	--slave /usr/bin/llvm-link         llvm-link        /usr/bin/llvm-link-3.6 \
	--slave /usr/bin/llvm-mc           llvm-mc          /usr/bin/llvm-mc-3.6 \
	--slave /usr/bin/llvm-mcmarkup     llvm-mcmarkup    /usr/bin/llvm-mcmarkup-3.6 \
	--slave /usr/bin/llvm-nm           llvm-nm          /usr/bin/llvm-nm-3.6 \
	--slave /usr/bin/llvm-objdump      llvm-objdump     /usr/bin/llvm-objdump-3.6 \
	--slave /usr/bin/llvm-ranlib       llvm-ranlib      /usr/bin/llvm-ranlib-3.6 \
	--slave /usr/bin/llvm-readobj      llvm-readobj     /usr/bin/llvm-readobj-3.6 \
	--slave /usr/bin/llvm-rtdyld       llvm-rtdyld      /usr/bin/llvm-rtdyld-3.6 \
	--slave /usr/bin/llvm-size         llvm-size        /usr/bin/llvm-size-3.6 \
	--slave /usr/bin/llvm-stress       llvm-stress      /usr/bin/llvm-stress-3.6 \
	--slave /usr/bin/llvm-symbolizer   llvm-symbolizer  /usr/bin/llvm-symbolizer-3.6 \
	--slave /usr/bin/llvm-tblgen       llvm-tblgen      /usr/bin/llvm-tblgen-3.6

RUN update-alternatives --install \
    /usr/bin/clang clang /usr/bin/clang-3.6 200 \
    --slave /usr/bin/clang++ clang++ /usr/bin/clang++-3.6  \
    --slave /usr/bin/lldb lldb /usr/bin/lldb-3.6 \
    --slave /usr/bin/clang-apply-replacements clang-apply-replacements /usr/bin/clang-apply-replacements-3.6 \
    --slave /usr/bin/clang-check clang-check /usr/bin/clang-check-3.6 \
    --slave /usr/bin/clang-format clang-format /usr/bin/clang-format-3.6 \
    --slave /usr/bin/clang-format-diff clang-format-diff /usr/bin/clang-format-diff-3.6 \
    --slave /usr/bin/clang-modernize clang-modernize /usr/bin/clang-modernize-3.6 \
    --slave /usr/bin/clang-query clang-query /usr/bin/clang-query-3.6 \
    --slave /usr/bin/clang-rename clang-rename /usr/bin/clang-rename-3.6 \
    --slave /usr/bin/clang-tblgen clang-tblgen /usr/bin/clang-tblgen-3.6 \
    --slave /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-3.6

# Copy install-clang files over.
ADD . /opt/install-clang

# Test clang and then delete install files
RUN cd /opt/install-clang && /opt/install-clang/testit && cd && rm -rf /opt/install-clang


