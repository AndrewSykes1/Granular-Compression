import torch
import numpy as np
import pandas as pd
import torch.nn.functional as F
from IPython.display import display

def chunkor(data,kernel):
    """
    Takes data and partitions it in 2 or 4 chunks wrt server and desktop gpu, 
    returning a padded, chunked list of the data; and a padded kernel, all in pytorch tensors.
    
    :param data: Default data to be processed
    :param kernel: An oddxoddxodd np array
    """

    device = torch.cuda.get_device_name()
    if device == 'NVIDIA RTX A2000 12GB':
        client = 'Desktop'
        cuts = 2
    elif device == 'NVIDIA RTX 4000 Ada Generation':
        client = 'Server'
        cuts = 1

    info = [torch.cuda.get_device_properties(0).total_memory,
            torch.cuda.memory_reserved(0),
            torch.cuda.memory_allocated(0)]

    df = pd.DataFrame([np.round(item/(1024**3),2) for item in info],
                      index=['Total','Reserved','Allocated'],columns=['VRam'])

    assert all(i % 2 == 1 for i in kernel.shape), 'Kernel dimensions must be odd!'
    assert all(i % 2 == 0 for i in data.shape), 'Data dimensions must be even!'

    print(f'{client} device detected: {device}')
    print(f'Data Ram: {np.round(data.nbytes/(1024**3),2)} GB')
    print(f'Attempting {2**cuts} partitions')
    display(df)

    r,c,z = data.shape
    pads = int(kernel.shape[0]/2)

    lower = data[:,:,0:int(z/2)+pads] # Lower Half
    upper = data[:,:,int(z/2)-pads:z] # Upper Half

    if cuts==1:
        chunks = [lower,upper]
    elif cuts == 2:
        chunks = [lower[:,0:int(c/2)+pads,:],
                  lower[:,int(c/2)-pads:c,:],
                  upper[:,0:int(c/2)+pads,:],
                  upper[:,int(c/2)-pads:c,:]]
    
    pchunks = [F.pad(torch.from_numpy(chunk), pad=(pads,)*6) for chunk in chunks]
    pkernel =  F.pad(torch.from_numpy(kernel, pad=(pads,)*6))

    return pchunks, pkernel
