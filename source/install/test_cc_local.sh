#!/bin/bash
set -ex

if [ "$DP_VARIANT" = "cuda" ]; then
	CUDA_ARGS="-DUSE_CUDA_TOOLKIT=TRUE"
elif [ "$DP_VARIANT" = "rocm" ]; then
	CUDA_ARGS="-DUSE_ROCM_TOOLKIT=TRUE"
fi

#------------------

SCRIPT_PATH=$(dirname $(realpath -s $0))
NPROC=$(nproc --all)

#------------------

echo "try to find tensorflow in the Python environment"
INSTALL_PREFIX=${SCRIPT_PATH}/../../dp_test
BUILD_TMP_DIR=${SCRIPT_PATH}/../build_tests
PADDLE_INFERENCE_DIR=${BUILD_TMP_DIR}/paddle_inference_install_dir
mkdir -p ${BUILD_TMP_DIR}
cd ${BUILD_TMP_DIR}
cmake \
	-D ENABLE_TENSORFLOW=${ENABLE_TENSORFLOW:-TRUE} \
	-D ENABLE_PYTORCH=${ENABLE_PYTORCH:-TRUE} \
	-D ENABLE_PADDLE=${ENABLE_PADDLE:-TRUE} \
	-D INSTALL_TENSORFLOW=FALSE \
	-D USE_TF_PYTHON_LIBS=${ENABLE_TENSORFLOW:-TRUE} \
	-D USE_PT_PYTHON_LIBS=${ENABLE_PYTORCH:-TRUE} \
	-D CMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
	-D BUILD_TESTING:BOOL=TRUE \
	-D LAMMPS_VERSION=stable_22Jul2025_update2 \
	${CUDA_ARGS} ..
cmake --build . -j${NPROC} 2>&1 > cmake-build.log
tail -n 200 cmake-build.log 

cmake --install .
if [ "${ENABLE_PADDLE:-TRUE}" == "TRUE" ]; then
	PADDLE_INFERENCE_DIR=${BUILD_TMP_DIR}/paddle_inference_install_dir
	export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PADDLE_INFERENCE_DIR}/third_party/install/onednn/lib:${PADDLE_INFERENCE_DIR}/third_party/install/mklml/lib
fi

# export LD_PRELOAD when AddressSanitize is enabled
if echo "$CXXFLAGS" | grep -q "sanitize=.*address"; then
    export LD_PRELOAD="$(gcc -print-file-name=libasan.so)"
fi

# fix cannot find libdeepmd.so
export LD_LIBRARY_PATH=$(realpath $INSTALL_PREFIX)/lib:$LD_LIBRARY_PATH

# print more info for debug
export LD_DEBUG=libs
env | sort || true

# disable asan for unit test
# export ASAN_OPTIONS=halt_on_error=0:detect_leaks=0:abort_on_error=0:print_summary=0:report_free_failed=0

# run unit test
ctest --output-on-failure
