import numpy as np

def dwOptimizer(peakGrids, residuals, diameter, width):
    """
    Calculate one Newton's step toward minimizing residuals^2 over diameter and width.
    
    Parameters:
    -----------
    peakGrids
        Grid of distances from particle centers
    residuals
        Difference between model and actual image
    diameter
        Current particle diameter estimate
    width
        Current width parameter estimate
    
    Returns:
    --------
    del_diameter
        Change in diameter to minimize residuals
    del_width
        Change in width to minimize residuals
    """
    
    # Create general params
    particle_kern = peakGrids - diameter/2
    inv_width = 1/width
    hessian = np.zeros((2, 2))
    
    # Create starter functions
    tanh_term = np.tanh(particle_kern * inv_width)
    sech2_term = (1 / np.cosh(particle_kern * inv_width))**2
    
    # First partial derivatives
    dip_dD = inv_width * sech2_term / 4
    dip_dw = -particle_kern/2 * sech2_term
    
    # Second partial derivatives
    dip_DD = inv_width**2 / 4 * tanh_term * sech2_term
    dip_ww = particle_kern**2 * tanh_term * sech2_term
    dip_Dw = sech2_term * (1 - 2*inv_width * particle_kern * tanh_term) / 4
    
    # Gradient of "cost function"
    chi_D = residuals * dip_dD
    chi_w = residuals * dip_dw
    
    # Approximate Hessian of "cost function"
    chi_DD = dip_dD**2 + residuals * dip_DD
    chi_ww = dip_dw**2 + residuals * dip_ww
    chi_Dw = dip_dD * dip_dw + residuals * dip_Dw
    
    # Fill out approximate Hessian
    delta_arr = np.array([np.sum(chi_D), np.sum(chi_w)])
    hessian[0, 0] = np.sum(chi_DD)
    hessian[0, 1] = np.sum(chi_Dw)
    hessian[1, 0] = hessian[0, 1]
    hessian[1, 1] = np.sum(chi_ww)
    
    # Solve for parameter updates using pseudoinverse
    del_Dw = -delta_arr @ np.linalg.pinv(hessian)
    del_diameter = del_Dw[0]
    del_width = -inv_width * del_Dw[1] / (inv_width + del_Dw[1])
    
    return del_diameter, del_width