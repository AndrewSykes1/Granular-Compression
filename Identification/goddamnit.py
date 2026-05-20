import sys
import os
import importlib

parent = os.path.dirname(os.getcwd())
sys.path.insert(0, parent)

from Helpers import loadData, multiplot, sphereMask, saveData, chunker, unchunker, kernelPad
importlib.reload(sys.modules['Helpers.chunker'])
importlib.reload(sys.modules['Helpers.unchunker'])
importlib.reload(sys.modules['Helpers.kernelPad'])
importlib.reload(sys.modules['Helpers'])

import h5py
import matplotlib.pyplot as plt
import numpy as np
import stackview
from scipy.ndimage import zoom

path = r'C:\Users\Lab User\Desktop\ModernExperiments\exp_117\Scan_1.hdf5'
with h5py.File(path,"r") as f:
    print(list(f['RawData'].keys()))
    data = f['RawData']['Scan_1'][()]
    sz = np.shape(data)
    print(sz)

zData = zoom(data,.25)

stackview.picker(zData, continuous_update=True)