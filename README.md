Install clang/llvm into docker container

Docker
------

install-clang comes with a Dockerfile to build a Docker image, based
on Ubuntu, with clang/LLVM then in /opt/llvm:

    # make docker-build && make docker-run
    [... get a beer ...]
    root@f39b941f177c:/# clang --version
    clang version 3.5.0
    Target: x86_64-unknown-linux-gnu
    Thread model: posix
    root@f39b941f177c:/# which clang
    /opt/llvm/bin/clang

A prebuilt image is available at
https://registry.hub.docker.com/u/rsmmr/clang.

News
----

The install-clang script for LLVM 3.6 comes with a few changes
compared to earlier version:
* 3.6 now works out of the box in trusy, so just using apt packages

* The script now supports FreeBSD as well. (Contributed by Matthias
  Vallentin).

* The script now generally shared libraries for LLVM and clang, rather
  than static ones.

* As libc++abi now works well on Linux as well, we use it generally
  and no longer support libcxxrt.

* There are now command line options to select build mode and
  assertions explicitly.

* There's no 3rd phase anymore building assertion-enabled LLVM
  libraries, as changing compilation options isn't useful with shared
  libraries.

* In return, there's a phase 0 now if the system compiler isn't a
  clang; libc++abi needs clang that for its initial compilation
  already.

* There's now a Dockerfile to build an image with clang/LLVM in
  /opt/llvm.

[1]: http://clang.llvm.org
[2]: http://www.llvm.org
[3]: http://libcxx.llvm.org
[4]: http://compiler-rt.llvm.org
[5]: http://libcxxabi.llvm.org
