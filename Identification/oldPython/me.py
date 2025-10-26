import h5py
import numpy as np
import matplotlib.pyplot as plt
import datetime
import napari

from scipy.ndimage import gaussian_filter, binary_closing, distance_transform_edt
from skimage.morphology import ball
from skimage.feature import peak_local_max
from skimage.measure import label
from skimage.segmentation import watershed

def clock():
    now = datetime.datetime.now()
    now = now.time()
    current, trash = str(now).split(".")
    return current

x_start, x_end = 60, 965
y_start, y_end = 155, 1125 

print(f"{clock()} | Program started...")

#  Load 3D volume 
with h5py.File(r"C:\Users\Lab User\Desktop\experiment data\07292025\Scan_3.hdf5", "r") as f:
    data = f[r"RawData/Scan_3"][:, y_start:y_end, x_start:x_end]

print(f"{clock()} | Object loaded...")

# Smooth to reduce streak noise 
smoothed = gaussian_filter(data, sigma=2)

print(f"{clock()} | Applied Gaussian blur...")

# Threshold for each xz plane in the object
thresholded = np.zeros_like(smoothed, dtype=bool)
percent_thresh = 0.95 # What percent of the mean intensity a pixel must be to be included

for y in range(smoothed.shape[1]):  # loop over y-axis (rows)
    slice_ = smoothed[:, y, :] 
    mean_intensity = slice_.mean()
    threshold_value = mean_intensity * percent_thresh
    thresholded[:, y, :] = slice_ > threshold_value

print(f"{clock()} | Applied Binary threshold...")

# Morphological closing to fill dark streaks 
structure = np.array([[[0,0,0],
                       [0,1,0],
                       [0,0,0]],

                      [[0,1,0],
                       [1,1,1],
                       [0,1,0]],

                      [[0,0,0],
                       [0,1,0],
                       [0,0,0]]])
closed = binary_closing(thresholded, structure=structure, iterations=10)

print(f"{clock()} | Morphologically closed...")

# Distance transform 
distance = distance_transform_edt(closed)

print(f"{clock()} | Applied Distance transform...")

# Detect local maxima as markers 
local_maxi = peak_local_max(distance,
                            labels=closed,
                            min_distance=80,
                            footprint=ball(5))

print(f"{clock()} | Found local maxima on DT...")

z = closed.shape[0] // 2
fig, axs = plt.subplots(1, 4, figsize=(16, 4))

axs[0].imshow(smoothed[z], cmap='cool')
axs[0].set_title('Gaus')
axs[0].axis('off')

axs[1].imshow(thresholded[z], cmap='gray')
axs[1].set_title('Binary')
axs[1].axis('off')

axs[2].imshow(closed[z], cmap='gray')
axs[2].set_title('Morph')
axs[2].axis('off')

axs[3].imshow(distance[z], cmap='magma')
axs[3].set_title('Distance Transform')
axs[3].axis('off')

plt.tight_layout()
plt.show()

viewer = napari.Viewer()
viewer.add_image(smoothed, name='Smoothed', colormap='gray')
viewer.add_points(local_maxi, name='Local Maxima', size=30, face_color='red')
napari.run()