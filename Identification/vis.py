

from qtpy.QtWidgets import QSlider, QVBoxLayout, QWidget, QLabel
from qtpy.QtCore import Qt


import napari
from skimage.feature import peak_local_max

import sys
import os
import importlib

cur=os.getcwd()
paths = [cur := os.path.dirname(cur) for _ in range(3)]
sys.path.insert(0, paths[0])

from Helpers import loadData

import numpy as np
from magicgui import magicgui
from napari.layers import Image
import datetime
import pathlib
from magicgui import widgets



# Example 3D data
data = np.random.rand(100, 256, 256)

viewer = napari.Viewer()
layer = viewer.add_image(
    data.copy(),
    name="slabbed_volume",
    rendering="mip",  # or "average", "attenuated_mip"
)

@magicgui(
    z_min={"min": 0, "max": data.shape[0] - 1},
    z_max={"min": 0, "max": data.shape[0] - 1},
    call_button=False,
)
def slab_widget(z_min: int = 20, z_max: int = 40):
    if z_min > z_max:
        return

    slab = data.copy()
    slab[:z_min, :, :] = 0
    slab[z_max + 1 :, :, :] = 0

    layer.data = slab

viewer.window.add_dock_widget(slab_widget, area="right")
napari.run()
