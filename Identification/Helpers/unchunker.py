import numpy as np

def unchunker(chunks,kP,sZ):
    """
    Recombines kernel and padded chunks into their original stack and returns default data.
    
    :param chunks: Collection of kernel and blank padded arrays
    :param kP: Amount of kernel padding applied
    :param sZ: Original total data size -> data.shape
    """

    r,c,z = sZ
    if len(chunks) == 2:
        raise NotImplementedError
    elif len(chunks) == 4:
        ll,ul,lu,uu = chunks
        ll_unpad = ll[kP:-kP, kP:-kP, kP:-kP]  # Now shape (r, 266, z_chunk)
        ul_unpad = ul[kP:-kP, kP:-kP, kP:-kP]
        lu_unpad = lu[kP:-kP, kP:-kP, kP:-kP]  
        uu_unpad = uu[kP:-kP, kP:-kP, kP:-kP]
        columnComb1 = np.concatenate(
            (ll_unpad[:, :int(c/2), :],      # First 256 columns from ll
             lu_unpad[:, -int(c/2):, :]),    # Last 256 columns from lu
            axis=1
        )
        columnComb2 = np.concatenate(
            (ul_unpad[:, :int(c/2), :],      
             uu_unpad[:, -int(c/2):, :]),    
            axis=1
        )
        
        # Same logic for z-axis
        zedComb = np.concatenate(
            (columnComb1[:, :, :int(z/2)],   
             columnComb2[:, :, -int(z/2):]), 
            axis=2
        )
    
    default = zedComb[kP:-kP,kP:-kP,kP:-kP]
    return default