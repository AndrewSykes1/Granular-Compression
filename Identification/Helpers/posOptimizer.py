import numpy as np

def posOptimizer(pGrids, pGrids_x, pGrids_y, pGrids_z,
                 overlap, residuals, num_particles, diameter, width):
    """
    Calculate one Newton's step toward minimizing residuals^2 over particle centers.
    
    Parameters:
    -----------
    pGrids
        Grid of radial distances from particle centers
    pGrids_x
        Grid of x-components of distance vectors
    pGrids_y
        Grid of y-components of distance vectors
    pGrids_z
        Grid of z-components of distance vectors
    overlap
        Image showing which particle owns each voxel
    residuals
        Difference between model and actual image
    num_particles
        Number of particles
    diameter
        Particle diameter
    width
        Width parameter
    
    Returns:
    --------
    dx_positions
        Change in x positions for each particle
    dy_positions
        Change in y positions for each particle
    dz_positions
        Change in z positions for each particle
    """
    
    inv_width = 1 / width  # w is real width
    max_dr = 20  # max change per step
    
    hessian = np.zeros((3, 3))
    position_changes = np.zeros((num_particles, 3))
    
    # Create list of voxels for each particle
    flat_overlap = overlap.flatten()
    sorted_indices = np.argsort(flat_overlap)
    particle_counts = np.bincount(flat_overlap.astype(int), minlength=num_particles + 1)
    cumulative_counts = np.cumsum(particle_counts)
    
    # Useful numbers
    radial_distance = pGrids + np.finfo(float).eps
    radial_distance_cubed = radial_distance**3 + np.finfo(float).eps
    x_component = pGrids_x
    y_component = pGrids_y
    z_component = pGrids_z
    x_squared = x_component**2
    y_squared = y_component**2
    z_squared = z_component**2
    
    tanh_term = np.tanh((radial_distance - diameter/2) * inv_width)
    sech2_term = (1 / np.cosh((radial_distance - diameter/2) * inv_width))**2
    
    # First derivatives
    dip_dx = -inv_width * x_component * sech2_term / 2 / radial_distance
    dip_dy = -inv_width * y_component * sech2_term / 2 / radial_distance
    dip_dz = -inv_width * z_component * sech2_term / 2 / radial_distance
    
    # Second derivatives (diagonal)
    dip_dxx = inv_width * sech2_term * (2*inv_width*x_squared*radial_distance*tanh_term - (y_squared + z_squared)) / 2 / radial_distance_cubed
    dip_dyy = inv_width * sech2_term * (2*inv_width*y_squared*radial_distance*tanh_term - (x_squared + z_squared)) / 2 / radial_distance_cubed
    dip_dzz = inv_width * sech2_term * (2*inv_width*z_squared*radial_distance*tanh_term - (x_squared + y_squared)) / 2 / radial_distance_cubed
    
    # Second derivatives (off-diagonal)
    dip_dxy = inv_width * x_component * y_component * sech2_term * (2*inv_width*radial_distance*tanh_term + 1) / 2 / radial_distance_cubed
    dip_dxz = inv_width * x_component * z_component * sech2_term * (2*inv_width*radial_distance*tanh_term + 1) / 2 / radial_distance_cubed
    dip_dyz = inv_width * y_component * z_component * sech2_term * (2*inv_width*radial_distance*tanh_term + 1) / 2 / radial_distance_cubed
    
    # Gradient components
    chi_x = residuals * dip_dx
    chi_y = residuals * dip_dy
    chi_z = residuals * dip_dz
    
    # Hessian components
    chi_xx = dip_dx**2 + residuals * dip_dxx
    chi_yy = dip_dy**2 + residuals * dip_dyy
    chi_zz = dip_dz**2 + residuals * dip_dzz
    chi_xy = dip_dx * dip_dy + residuals * dip_dxy
    chi_xz = dip_dx * dip_dz + residuals * dip_dxz
    chi_yz = dip_dy * dip_dz + residuals * dip_dyz
    
    # Flatten arrays for indexing
    chi_x_flat = chi_x.flatten()
    chi_y_flat = chi_y.flatten()
    chi_z_flat = chi_z.flatten()
    chi_xx_flat = chi_xx.flatten()
    chi_yy_flat = chi_yy.flatten()
    chi_zz_flat = chi_zz.flatten()
    chi_xy_flat = chi_xy.flatten()
    chi_xz_flat = chi_xz.flatten()
    chi_yz_flat = chi_yz.flatten()
    
    # Loop over particles
    for particle_idx in range(num_particles):
        # Get indices for this particle's voxels
        start_idx = cumulative_counts[particle_idx]
        end_idx = cumulative_counts[particle_idx + 1]
        voxel_indices = sorted_indices[start_idx:end_idx]
        
        # Build gradient vector
        gradient = np.array([
            np.sum(chi_x_flat[voxel_indices]),
            np.sum(chi_y_flat[voxel_indices]),
            np.sum(chi_z_flat[voxel_indices])
        ])
        
        # Build Hessian matrix
        hessian[0, 0] = np.sum(chi_xx_flat[voxel_indices])
        hessian[0, 1] = np.sum(chi_xy_flat[voxel_indices])
        hessian[0, 2] = np.sum(chi_xz_flat[voxel_indices])
        hessian[1, 0] = hessian[0, 1]
        hessian[1, 1] = np.sum(chi_yy_flat[voxel_indices])
        hessian[1, 2] = np.sum(chi_yz_flat[voxel_indices])
        hessian[2, 0] = hessian[0, 2]
        hessian[2, 1] = hessian[1, 2]
        hessian[2, 2] = np.sum(chi_zz_flat[voxel_indices])
        
        # Newton's step
        position_changes[particle_idx, :] = gradient @ np.linalg.pinv(hessian)
    
    dx_positions = position_changes[:, 0]
    dy_positions = position_changes[:, 1]
    dz_positions = position_changes[:, 2]
    
    # Limit step size to max_dr
    position_change_magnitude = np.sqrt(dx_positions**2 + dy_positions**2 + dz_positions**2)
    large_step_mask = position_change_magnitude > max_dr
    dx_positions[large_step_mask] = dx_positions[large_step_mask] / position_change_magnitude[large_step_mask] * max_dr
    dy_positions[large_step_mask] = dy_positions[large_step_mask] / position_change_magnitude[large_step_mask] * max_dr
    dz_positions[large_step_mask] = dz_positions[large_step_mask] / position_change_magnitude[large_step_mask] * max_dr
    
    return dx_positions, dy_positions, dz_positions