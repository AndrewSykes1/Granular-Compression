import numpy as np
import scipy.io as sio
import h5py
import os
import napari

from qtpy.QtWidgets import QSlider, QVBoxLayout, QWidget, QLabel
from qtpy.QtCore import Qt
from scipy.ndimage import zoom
from DataViewer import DataViewer

