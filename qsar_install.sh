#!/bin/bash

conda remove --name qsar --all --yes
conda env create -f qsar.yml -n qsar

conda activate qsar
python -m ipykernel install --user --name qsar --display-name "Python 3.12 (QSAR)"