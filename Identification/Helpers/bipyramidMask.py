import numpy as np
from math import pi,cos,sin
from matplotlib.path import Path

def bipyramidMask(n, R, H, hr, pad=0, scale=1):
    """
    Creates a binary bipyramid mask with a cylindrical hole through the center

    Parameters:
    :param n:     Number of sides on the base polygon
    :param R:     Radius of the bipyramid base
    :param H:     Height of each pyramid (total height = 2*H)
    :param hr:    Radius of the cylindrical hole
    :param pad:   Blank side padding
    :param scale: Downscaled magnitude compared to reality (.25 => OG*.25=Scan)
    """

    # Scale parameters
    R   = round(R*scale)
    H   = round(H*scale)
    hr  = round(hr*scale)
    pad = round(pad*scale)

    # Kernel volume
    cx = R+pad;   cy = R+pad
    W  = 2*cx+1;  D  = 2*cy+1;  T = 2*H+1

    # Create kernel and thetas - shape (r,c,z)
    kernel = np.zeros((W, D, T), dtype=np.uint8)
    thetas = [i*(2*pi/n) for i in range(n)]

    # Create circular hole path
    circle_verts = [(cx + hr*cos(i*(2*pi/100)), cy + hr*sin(i*(2*pi/100))) for i in range(100)]
    hole = Path(circle_verts + [circle_verts[0]])

    # Pixel grid
    xs, ys = np.meshgrid(np.arange(W), np.arange(D))
    points = np.column_stack([xs.ravel(), ys.ravel()])

    for z in range(T):
        dz = abs(z-H)   # Distance from equator
        r  = R*(1-dz/H) # Decrease radius linearly w/height

        if r <= 0:
            continue

        # Create 2d slice polygon
        verts = [(cx + r*cos(th), cy + r*sin(th)) for th in thetas]
        path  = Path(verts + [verts[0]])

        # Raycast to fill internals, remove hole
        mask  = path.contains_points(points)
        empty = hole.contains_points(points)

        # Remove hole, scale to 255, assign to z slice - (r,c,z)
        kernel[:, :, z] = (mask & ~empty).reshape(D, W).T * 255

    return kernel