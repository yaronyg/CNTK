#!/usr/bin/env bash
set -e

rm -f com/microsoft/CNTK/*.java
swig -c++ -java -package com.microsoft.CNTK -I/home/ratan/CNTK/Source/CNTKv2LibraryDll/API -I/home/ratan/CNTK/bindings/common -I/home/ratan/CNTK/Source/Common/Include -outdir com/microsoft/CNTK cntk_java.i
javac com/microsoft/CNTK/*.java
jar -cvf cntk.jar com
export OMPI_CXX=g++-4.8
mpic++ -shared -DCPUONLY -DNOSYNC -D_POSIX_SOURCE -D_XOPEN_SOURCE=600 -D__USE_XOPEN2K -std=c++0x -fopenmp -fpermissive -fPIC -Werror -fcheck-new -DSWIG -I/home/ratan/CNTK/Source/Include -I/home/ratan/CNTK/Source/CNTKv2LibraryDll/API -I/home/ratan/CNTK/Source/Common/Include -I/home/ratan/lib/jdk/include -I/home/ratan/lib/jdk/include/linux cntk_java_wrap.cxx -L/home/ratan/CNTK/build/release/lib -lcntkmath -lcntklibrary-2.0 -L/usr/local/protobuf-3.1.0/lib -lprotobuf -o libCNTKJava.so
echo "done"
