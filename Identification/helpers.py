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