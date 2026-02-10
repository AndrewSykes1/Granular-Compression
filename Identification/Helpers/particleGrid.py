import numpy as np

def particleGrid(xPeakPos, yPeakPos, zPeakPos, 
                 gridWidth, gridHeight, gridDepth,
                 boundaryBox, peakCount, kpSize, useRadius):
    """
    Create a local grid centered on each particle and an overlap matrix for Voronoi volumes
    
    Parameters:
    -----------
    xPeakPos
        X coordinates of peak positions
    yPeakPos
        Y coordinates of peak positions
    zPeakPos
        Z coordinates of peak positions
    gridWidth
        Width of the grid (x dimension)
    gridHeight
        Height of the grid (y dimension)
    gridDepth
        Depth of the grid (z dimension)
    boundaryBox : array-like
        Box boundaries [x_min, x_max, y_min, y_max, z_min, z_max]
    peakCount
        Number of peaks/particles
    kpSize : float
        Size of the kernel padding region
    useRadius : bool
        If True, use absolute distance; if False, use complex-like distance
    
    Returns:
    --------
    particleGrid : ndarray
        Grid with distances/vectors from nearest particle
    overlapMap : ndarray
        Image showing which particle owns each voxel in its Voronoi region
    """
    
    # Handle empty input
    if len(xPeakPos) == 0:
        particleGrid = np.zeros((gridWidth, gridHeight, gridDepth))
        overlapMap = np.zeros((gridWidth, gridHeight, gridDepth))
        return particleGrid, overlapMap
    
    # Extract boundary coordinates
    x_min = boundaryBox[0]
    x_max = boundaryBox[1]
    y_min = boundaryBox[2]
    y_max = boundaryBox[3]
    z_min = boundaryBox[4]
    z_max = boundaryBox[5]
    
    # Create coordinate meshgrids
    x_coords, y_coords, z_coords = np.meshgrid(
        np.arange(1, gridWidth + 1),
        np.arange(1, gridHeight + 1),
        np.arange(1, gridDepth + 1),
        indexing='ij'
    )
    
    # Initialize particle grid with large values
    max_dimension = max(gridWidth, gridHeight, gridDepth)
    particleGrid = np.ones((gridWidth, gridHeight, gridDepth)) * max_dimension
    
    # Initialize overlap map (tracks which particle owns each voxel)
    overlapMap = np.zeros((gridWidth, gridHeight, gridDepth))
    
    # Define kernel range (region around each particle to check)
    half_kernel = int(np.ceil(kpSize / 2))
    kernel_offset = np.arange(-half_kernel, half_kernel + 1)
    
    # Process each particle/peak
    for particle_idx in range(peakCount):
        # Calculate extended kernel range around this particle
        kernel_range_x = np.round(xPeakPos[particle_idx]) + kernel_offset
        kernel_range_y = np.round(yPeakPos[particle_idx]) + kernel_offset
        kernel_range_z = np.round(zPeakPos[particle_idx]) + kernel_offset
        
        # Clip to boundary box
        valid_x = kernel_range_x[(kernel_range_x <= x_max) & (kernel_range_x >= x_min)].astype(int)
        valid_y = kernel_range_y[(kernel_range_y <= y_max) & (kernel_range_y >= y_min)].astype(int)
        valid_z = kernel_range_z[(kernel_range_z <= z_max) & (kernel_range_z >= z_min)].astype(int)
        
        # Only process if particle influence is inside boundary
        if valid_x.size > 0 and valid_y.size > 0 and valid_z.size > 0:
            valid_x_idx = valid_x - 1
            valid_y_idx = valid_y - 1
            valid_z_idx = valid_z - 1
            
            # Calculate distance from particle to each grid point in the region
            delta_x = x_coords[np.ix_(valid_x_idx, valid_y_idx, valid_z_idx)] - xPeakPos[particle_idx]
            delta_y = y_coords[np.ix_(valid_x_idx, valid_y_idx, valid_z_idx)] - yPeakPos[particle_idx]
            delta_z = z_coords[np.ix_(valid_x_idx, valid_y_idx, valid_z_idx)] - zPeakPos[particle_idx]
            
            if useRadius:
                # Use absolute(Euclidean) distance 
                distance_grid = np.sqrt(delta_x**2 + delta_y**2 + delta_z**2)
                
                # Find voxels where this particle is closer than current assignment
                closer_mask = particleGrid[np.ix_(valid_x_idx, valid_y_idx, valid_z_idx)] >= distance_grid
                closer_x, closer_y, closer_z = np.where(closer_mask)
                
                # Update overlap map and particle grid for closer voxels
                for i, j, k in zip(closer_x, closer_y, closer_z):
                    overlapMap[valid_x_idx[i], valid_y_idx[j], valid_z_idx[k]] = particle_idx + 1  # 1-indexed
                    particleGrid[valid_x_idx[i], valid_y_idx[j], valid_z_idx[k]] = distance_grid[i, j, k]
                    
            else:
                # Store vector distance for derivative calculations
                distance_grid = np.sqrt(delta_x**2 + delta_y**2 + delta_z**2)
                
                # Find voxels where this particle is closer than current assignment
                closer_mask = particleGrid[np.ix_(valid_x_idx, valid_y_idx, valid_z_idx)] >= distance_grid
                closer_x, closer_y, closer_z = np.where(closer_mask)
                
                # Update overlap map and particle grid for closer voxels
                for i, j, k in zip(closer_x, closer_y, closer_z):
                    overlapMap[valid_x_idx[i], valid_y_idx[j], valid_z_idx[k]] = particle_idx + 1  # 1-indexed
                    particleGrid[valid_x_idx[i], valid_y_idx[j], valid_z_idx[k]] = distance_grid[i, j, k]
    
    return particleGrid, overlapMap