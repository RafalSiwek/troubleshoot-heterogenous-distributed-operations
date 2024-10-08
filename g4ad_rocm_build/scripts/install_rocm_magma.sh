
#!/bin/bash
# Script used in CI and CD pipeline

set -ex


MKLROOT=${MKLROOT:-/opt/conda/envs/py_$ANACONDA_PYTHON_VERSION}

# "install" hipMAGMA into /opt/rocm/magma by copying after build
git clone https://github.com/icl-utk-edu/magma.git
pushd magma

cp make.inc-examples/make.inc.hip-gcc-mkl make.inc
echo 'LIBDIR += -L$(MKLROOT)/lib' >> make.inc
if [[ -f "${MKLROOT}/lib/libmkl_core.a" ]]; then
    echo 'LIB = -Wl,--start-group -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -Wl,--end-group -lpthread -lstdc++ -lm -lgomp -lhipblas -lhipsparse' >> make.inc
fi
echo 'LIB += -Wl,--enable-new-dtags -Wl,--rpath,/opt/rocm/lib -Wl,--rpath,$(MKLROOT)/lib -Wl,--rpath,/opt/rocm/magma/lib -ldl' >> make.inc
echo 'DEVCCFLAGS += --gpu-max-threads-per-block=256' >> make.inc
export PATH="${PATH}:/opt/rocm/bin"

echo "GPU_TARGET  = gfx1011" >> make.inc

# hipcc with openmp flag may cause isnan() on __device__ not to be found; depending on context, compiler may attempt to match with host definition
sed -i 's/^FOPENMP/#FOPENMP/g' make.inc
make -f make.gen.hipMAGMA -j $(nproc)
LANG=C.UTF-8 make lib/libmagma.so -j $(nproc) MKLROOT="${MKLROOT}"
make testing/testing_dgemm -j $(nproc) MKLROOT="${MKLROOT}"
popd
mv magma /opt/rocm
