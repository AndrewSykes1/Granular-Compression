def sech(x): 
    return 1 / np.cosh(x)

def normalize(img): 
    return np.clip((img - img.min()) / (img.max() - img.min()), 0, 1)

def ipf3D(cr, D, w): 
    return (1 - np.tanh((np.abs(cr) - D/2)/w)) / 2

def convolution3D_FFTdomain(img, kernel): 
    return fftconvolve(img, kernel, mode='same')

def chiimg3D_FFT(img, ip, W=None, Wip2=None):
    if W is None: 
        W = ip
    if Wip2 is None: 
        Wip2 = convolution3D_FFTdomain(np.ones_like(img), ip**2 * W)
    return 1 + (-2*convolution3D_FFTdomain(img, ip*W) + convolution3D_FFTdomain(img**2, W))/Wip2, Wip2

def findpeaks3D(img, CutOff=0, MinSep=1):
    coords = peak_local_max(img, min_distance=int(MinSep), threshold_abs=CutOff)
    spx, spy, spz = coords[:, 2], coords[:, 1], coords[:, 0]  # XYZ
    return len(spx), spx, spy, spz

def pgrid3D(spx, spy, spz, Nx, Ny, Nz, Np, radLen, rad):
    over = np.zeros((Ny, Nx, Nz), dtype=int)
    cr = type('', (), {})()
    cr.x = np.zeros((Ny, Nx, Nz))
    cr.y = np.zeros((Ny, Nx, Nz))
    cr.z = np.zeros((Ny, Nx, Nz))
    for np_idx in range(Np):
        xi = np.clip(np.round(spx[np_idx]) + np.arange(-radLen, radLen+1), 0, Nx-1).astype(int)
        yi = np.clip(np.round(spy[np_idx]) + np.arange(-radLen, radLen+1), 0, Ny-1).astype(int)
        zi = np.clip(np.round(spz[np_idx]) + np.arange(-radLen, radLen+1), 0, Nz-1).astype(int)
        XX, YY, ZZ = np.meshgrid(xi, yi, zi, indexing='ij')
        crx, cry, crz = XX - spx[np_idx], YY - spy[np_idx], ZZ - spz[np_idx]
        dist = np.sqrt(crx**2 + cry**2 + crz**2)
        mask = dist < np.sqrt(cr.x[YY,XX,ZZ]**2 + cr.y[YY,XX,ZZ]**2 + cr.z[YY,XX,ZZ]**2)
        over[YY[mask], XX[mask], ZZ[mask]] = np_idx + 1
        cr.x[YY[mask], XX[mask], ZZ[mask]] = crx[mask]
        cr.y[YY[mask], XX[mask], ZZ[mask]] = cry[mask]
        cr.z[YY[mask], XX[mask], ZZ[mask]] = crz[mask]
    return cr, over

def cidp23D(cxyz, over, di, Np, D, w):
    w = 1/w
    maxdr = 2
    dpx = np.zeros(Np)
    dpy = np.zeros(Np)
    dpz = np.zeros(Np)
    rr = np.sqrt(cxyz.x**2 + cxyz.y**2 + cxyz.z**2) + 1e-12
    tanh1 = np.tanh((rr - D/2)*w)
    sech2 = sech((rr - D/2)*w)**2
    dipx = -w*cxyz.x*sech2/(2*rr)
    dipy = -w*cxyz.y*sech2/(2*rr)
    dipz = -w*cxyz.z*sech2/(2*rr)
    dipxx = w*sech2*(2*w*cxyz.x**2*rr*tanh1 - cxyz.y**2 - cxyz.z**2)/(2*rr**3)
    dipyy = w*sech2*(2*w*cxyz.y**2*rr*tanh1 - cxyz.x**2 - cxyz.z**2)/(2*rr**3)
    dipzz = w*sech2*(2*w*cxyz.z**2*rr*tanh1 - cxyz.x**2 - cxyz.y**2)/(2*rr**3)
    dipxy = w*cxyz.x*cxyz.y*sech2*(2*w*rr*tanh1+1)/(2*rr**3)
    dipxz = w*cxyz.x*cxyz.z*sech2*(2*w*rr*tanh1+1)/(2*rr**3)
    dipyz = w*cxyz.y*cxyz.z*sech2*(2*w*rr*tanh1+1)/(2*rr**3)
    overVec, diVec = over.flatten(), di.flatten()
    dipxVec, dipyVec, dipzVec = dipx.flatten(), dipy.flatten(), dipz.flatten()
    dipxxVec, dipyyVec, dipzzVec = dipxx.flatten(), dipyy.flatten(), dipzz.flatten()
    dipxyVec, dipxzVec, dipyzVec = dipxy.flatten(), dipxz.flatten(), dipyz.flatten()
    for np_idx in range(Np):
        idx = np.where(overVec == np_idx + 1)[0]
        b = np.array([np.sum(diVec[idx]*dipxVec[idx]),
                      np.sum(diVec[idx]*dipyVec[idx]),
                      np.sum(diVec[idx]*dipzVec[idx])])
        A = np.array([[np.sum(dipxVec[idx]**2 + diVec[idx]*dipxxVec[idx]),
                       np.sum(dipxVec[idx]*dipyVec[idx] + diVec[idx]*dipxyVec[idx]),
                       np.sum(dipxVec[idx]*dipzVec[idx] + diVec[idx]*dipxzVec[idx])],
                      [np.sum(dipxVec[idx]*dipyVec[idx] + diVec[idx]*dipxyVec[idx]),
                       np.sum(dipyVec[idx]**2 + diVec[idx]*dipyyVec[idx]),
                       np.sum(dipyVec[idx]*dipzVec[idx] + diVec[idx]*dipyzVec[idx])],
                      [np.sum(dipxVec[idx]*dipzVec[idx] + diVec[idx]*dipxzVec[idx]),
                       np.sum(dipyVec[idx]*dipzVec[idx] + diVec[idx]*dipyzVec[idx]),
                       np.sum(dipzVec[idx]**2 + diVec[idx]*dipzzVec[idx])]])
        dp = b @ np.linalg.pinv(A + 1e-6*np.eye(3))
        stepMag = np.linalg.norm(dp)
        if stepMag > maxdr: dp = dp/max(stepMag,1e-12)*maxdr
        dpx[np_idx], dpy[np_idx], dpz[np_idx] = dp
    return dpx, dpy, dpz

def CircleOverlap(c1, c2):
    x1, y1, r1 = c1
    x2, y2, r2 = c2
    d = hypot(x1 - x2, y1 - y2)

    if d >= r1 + r2:  # No overlap
        return 0.0
    if d <= abs(r1 - r2):  # One inside the other
        return (pi * min(r1, r2)**2) / (pi * max(r1, r2)**2)

    r1_sq = r1**2
    r2_sq = r2**2

    alpha = acos((d**2 + r1_sq - r2_sq) / (2 * d * r1))
    beta = acos((d**2 + r2_sq - r1_sq) / (2 * d * r2))

    area1 = r1_sq * alpha
    area2 = r2_sq * beta
    area3 = 0.5 * sqrt((-d + r1 + r2) * (d + r1 - r2) * (d - r1 + r2) * (d + r1 + r2))

    intersection = area1 + area2 - area3
    union = pi * r1_sq + pi * r2_sq - intersection
    return intersection / union

def CircleOverlap(c1, c2):
    # simple IoU-like overlap (replace with your actual implementation)
    x1, y1, r1 = c1
    x2, y2, r2 = c2
    d = np.hypot(x1 - x2, y1 - y2)
    if d > r1 + r2:
        return 0.0
    return 1.0 - d / (r1 + r2)

def CircleDetection(
    img,
    min_r=10,
    max_r=60,
    step=2,
    sigma=2.75,
    threshold=100,
    iou_thresh=0.25
):
    # Step 1: Edge detection
    img = img
    edges = canny(img, sigma=sigma)
    h, w = edges.shape

    # Step 2: Radii
    radii = np.arange(min_r, max_r, step)
    num_radii = len(radii)

    # Step 3: Precompute circle perimeters (stacked)
    theta = np.arange(0, 2 * pi, pi / 180)
    cos_t, sin_t = np.cos(theta), np.sin(theta)
    dx_all = np.round(radii[:, None] * cos_t).astype(int)
    dy_all = np.round(radii[:, None] * sin_t).astype(int)

    # Step 4: Voting (vectorized)
    y_idxs, x_idxs = np.nonzero(edges)  # edge points (N,)
    N = len(x_idxs)

    # Expand edge coords against circle offsets
    # Shape: (num_radii, N, num_theta)
    x_c = x_idxs[None, :, None] - dx_all[:, None, :]
    y_c = y_idxs[None, :, None] - dy_all[:, None, :]

    # Keep only valid centers
    valid = (x_c >= 0) & (x_c < w) & (y_c >= 0) & (y_c < h)

    # Flatten into 1D indices for bincount
    flat_idx = (y_c * w + x_c) * num_radii + np.arange(num_radii)[:, None, None]
    flat_idx = np.where(valid, flat_idx, -1).ravel()

    flat_idx = flat_idx[flat_idx >= 0]  # remove invalid

    accumulator = np.bincount(flat_idx, minlength=h * w * num_radii).reshape(h, w, num_radii)

    # Step 5: Candidate detection
    candidates = []
    for r_index, r in enumerate(radii):
        acc_slice = accumulator[:, :, r_index]
        local_max = (maximum_filter(acc_slice, size=5) == acc_slice)
        mask = (acc_slice > threshold) & local_max
        coords = np.argwhere(mask)

        if coords.size > 0:
            vals = acc_slice[coords[:, 0], coords[:, 1]]
            for (y, x), val in zip(coords, vals):
                neighbors = []
                for offset in [-2, -1, 1, 2]:
                    neighbor_idx = r_index + offset
                    if 0 <= neighbor_idx < num_radii:
                        neighbors.append(accumulator[y, x, neighbor_idx])
                if all(val > n for n in neighbors):
                    candidates.append((x, y, r, val))

    # Step 6: IoU filtering
    final_circles = []
    for x, y, r, val in sorted(candidates, key=lambda c: -c[3]):
        this_circle = (x, y, r)
        keep = True
        for fx, fy, fr in final_circles:
            if CircleOverlap(this_circle, (fx, fy, fr)) > iou_thresh:
                keep = False
                break
        if keep:
            final_circles.append(this_circle)

    return final_circles

def find_peaks(a):
  x = np.array(a)
  max = np.max(x)
  length = len(a)
  ret = []
  for i in range(length):
      ispeak = True
      if i-1 > 0:
          ispeak &= (x[i] > 1.8 * x[i-1])
      if i+1 < length:
          ispeak &= (x[i] > 1.8 * x[i+1])
    
      ispeak &= (x[i] > 0.05 * max)
      if ispeak:
          ret.append(i)
  return ret

def RemoveArtifacts(img, circles, radius_padding=3):

    cleaned = img.copy()
    gradient = sobel(img)

    for x, y, r in circles:
        # Step 1: Create initial mask from circle
        rr, cc = disk((y, x), r - radius_padding, shape=img.shape)
        init_mask = np.zeros(img.shape, dtype=bool)
        init_mask[rr, cc] = True

        # Step 2: Refine region using active contour
        snake = mgac(
            gradient,        # image
            1,              # iterations
            init_mask,       # initial level set
            smoothing=1,
            threshold='auto',
            balloon=-5
        )
        refined_mask = snake > 0.5

        # Step 3: Fill internal noise (e.g., laser lines) inside the particle
        region_vals = img[refined_mask]
        counts, bin_edges = np.histogram(region_vals.flatten(), bins = 20)
        common_val_idx = np.argmax(counts)
        common_val = bin_edges[common_val_idx]
        
        noise = (refined_mask & (img < common_val - 0.05))
        cleaned[noise] = common_val*1.2

    return cleaned
