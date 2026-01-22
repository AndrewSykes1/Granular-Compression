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
        columnComb1 = np.concatenate((ll[:,:int(c/2),:],lu[:,kP:,:]),axis=1)
        columbComb2 = np.concatenate((ul[:,:int(c/2),:],uu[:,kP:,:]),axis=1)
        zedComb = np.concatenate((columnComb1[:,:,:int(z/2)],
                                  columbComb2[:,:,kP:]),
                                  axis=2)
    
    default = zedComb[kP:-kP,kP:-kP,kP:-kP]
    return default