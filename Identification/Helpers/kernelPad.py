import numpy as np
def kernelPad(kernel, chunk):
    """
    Pads kernel into the same size as chunk
    
    :param kernel: Sphere mask
    :param chunk: One of the chunks in padded chunks list
    """

    eP = [int((aC-kernel.shape[idx])/2) for idx,aC in enumerate(chunk.shape)]
    pKern = np.pad(kernel, pad_width=((eP[0],eP[0]),
                                      (eP[1],eP[1]),
                                      (eP[2],eP[2])))
    return pKern