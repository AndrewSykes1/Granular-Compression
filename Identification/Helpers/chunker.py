import numpy as np

def chunker(data, kP, device):
    """
    Chunks data into proper sizes depending on the device. 
    Outputs list containing chunks alongside their kernel Padding in the column z order
    of ll, ul, lu, uu.
    
    :param data: Entire dataset
    :param kP: Kernel padding size: (kernel.shape[0]/2)+1
    :param device: Desktop or Server specification
    """

    r,c,z = data.shape
    upper = data[:,:,   int(z/2)-kP: ] # U
    lower = data[:,:, 0:int(z/2)+kP  ] # L

    if device == 'Server':
        kChunks = [lower,upper]

    if device == 'Desktop':
        ul,uu = upper[:, :int(c/2)+kP ,:], upper[:, int(c/2)-kP: ,:]
        ll,lu = lower[:, :int(c/2)+kP ,:], lower[:, int(c/2)-kP: ,:]
        kChunks = [ll,ul,lu,uu]

    else:
        print('Device not identified')
        raise TypeError

    pChunks = [np.pad(chunk,pad_width=((kP,kP),(kP,kP),(kP,kP))) for chunk in kChunks]

    return pChunks
    