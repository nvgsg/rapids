#!/bin/bash

set -eu

if [ ! -f Miniconda3-4.5.4-Linux-x86_64.sh ]; then
    echo "Removing conflicting packages, will replace with RAPIDS compatible versions"
    # remove existing xgboost and dask installs
    pip uninstall -y xgboost dask distributed

    # intall miniconda
    echo "Installing conda"
    wget https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh
    chmod +x Miniconda3-4.5.4-Linux-x86_64.sh
    bash ./Miniconda3-4.5.4-Linux-x86_64.sh -b -f -p /usr/local
	
	#pin python3.6
	echo "python 3.6.*" > /usr/local/conda-meta/pinned
	
	#Installing another conda package first something first seems to fix https://github.com/rapidsai/rapidsai-csp-utils/issues/4
	conda install --channel defaults conda python=3.6 --yes
	conda update -y -c conda-forge -c defaults --all
	conda install -y --prefix /usr/local -c conda-forge -c defaults openssl six

    echo "Installing RAPIDS packages"
    echo "Please standby, this will take a few minutes..."
    # install RAPIDS packages
    conda install -y --prefix /usr/local \
      -c rapidsai/label/xgboost -c rapidsai -c nvidia -c conda-forge -c defaults \
      python=3.6 cudatoolkit=10.0 \
      cudf=0.8 cuml=0.8 cugraph=0.8 gcsfs pynvml \
      dask-cudf=0.8 dask-cuml=0.8 \
      rapidsai/label/xgboost::xgboost=>0.8 numba=0.48
      
	echo "Copying shared object files to /usr/lib"
	# copy .so files to /usr/lib, where Colab's Python looks for libs
	cp /usr/local/lib/libcudf.so /usr/lib/libcudf.so
	cp /usr/local/lib/librmm.so /usr/lib/librmm.so
	cp /usr/local/lib/libnccl.so /usr/lib/libnccl.so
	echo "Copying RAPIDS compatible xgboost"	
	cp /usr/local/lib/libxgboost.so /usr/lib/libxgboost.so
	
	echo "Pin cffi library due to incompatibility with newer numba"
	pip install cffi==1.14.3 matplotlib
fi

echo ""
echo "************************************************"
echo "Your Colab instance has RAPIDS installed!"
echo "************************************************"
