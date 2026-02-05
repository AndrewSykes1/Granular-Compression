import napari
from qtpy.QtWidgets import QSlider, QVBoxLayout, QWidget, QLabel
from qtpy.QtCore import Qt
from skimage.feature import peak_local_max

import sys
import os
import importlib
from magicgui import magicgui
import datetime
import pathlib
from magicgui import widgets

cur=os.getcwd()
paths = [cur := os.path.dirname(cur) for _ in range(3)]
sys.path.insert(0, paths[0])

from Helpers import loadData


data = loadData(location=os.path.join(paths[0],'Data'), 
                fileName='convMap_17.hdf5')
peaks = peak_local_max(data)

dim = data.shape
low  = widgets.Slider(value=0, min=0, max=dim[-1], label="b")
high = widgets.Slider(value=0, min=0, max=dim[-1], label="b")
container = widgets.Container(widgets=[low,high])
container.show()