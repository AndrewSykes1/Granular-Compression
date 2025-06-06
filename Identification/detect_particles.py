import numpy as np
import cv2
from skimage.exposure import equalize_adapthist
from scipy.signal import fftconvolve
from scipy.ndimage import maximum_filter
import matplotlib.pyplot as plt

def ipf(r, D, w):
    return np.exp(-(r - D / 2) ** 2 / (2 * w ** 2))

def chiimg(img, template):
    return fftconvolve(img, template[::-1, ::-1], mode='same')

def detect_particles(image, show=False):

    original = image.copy()
    resized = cv2.resize(original, (0, 0), fx=0.1, fy=0.1)
    
    lo, hi = resized.min(), resized.max()
    D = 4
    w = D/6
    Cutoff = 2

    norm = (resized.astype(np.float32) - lo) / (hi - lo)
    norm = np.clip(norm, 0, 1)
    norm = 1 - norm


    plt.imshow(norm, cmap='gray')
    plt.show()
    #norm = equalize_adapthist(norm_inv)

    plt.imshow(norm, cmap='gray')
    plt.show()

    ss = 2 * int(D / 2 + 4 * w / 2) - 1
    os = (ss - 1) // 2
    xx, yy = np.meshgrid(np.arange(-os, os+1), np.arange(-os, os+1))
    r = np.hypot(xx, yy)
    template = ipf(r, D, w)
    template = 1 - template


    conv = 1 / (chiimg(norm, template) + 1e-6)

    plt.imshow(conv, cmap='gray')
    plt.show()

    # --- NEW: 2D Peak detection ---
    neighborhood = maximum_filter(conv, size=5)
    peaks_mask = (conv == neighborhood) & (conv > Cutoff)
    peak_coords = np.argwhere(peaks_mask)

    # Scale detected positions back to original image size
    scale = original.shape[0] / resized.shape[0]
    coords = peak_coords[:, [1, 0]] * scale  # [x, y] format

    # Filter out-of-bounds
    h, w = original.shape[:2]
    valid = (coords[:, 0] >= 0) & (coords[:, 0] <= w) & (coords[:, 1] >= 0) & (coords[:, 1] <= h)
    coords = coords[valid]

    if show:
        if original.ndim == 2:  # grayscale
            plt.imshow(original, cmap='gray')
        else:  # color
            plt.imshow(cv2.cvtColor(original, cv2.COLOR_BGR2RGB))
        plt.scatter(coords[:, 0], coords[:, 1], c='red', s=10)
        plt.title('Detected Particle Centers')
        plt.axis('off')
        plt.show()


    return coords
