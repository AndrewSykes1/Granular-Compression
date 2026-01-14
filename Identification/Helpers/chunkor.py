import torch
import numpy as np
import pandas as pd
from IPython.display import display

def chunkor(data,kernel):
    """
    Docstring for chunkor
    
    :param data: Description
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

    print(f'{client} device detected: {device}')
    print(f'Data Ram: {np.round(data.nbytes/(1024**3),2)} GB')
    print(f'Attempting {2**cuts} partitions')
    display(df)

    r,c,z = data.shape
    pad = int(kernel.shape[0]/2)

    lower = data[:,:,0:int(z/2)+pad] # Lower Half
    upper = data[:,:,int(z/2)-pad:z] # Upper Half

    if cuts==1:
        chunks = [lower,upper]
    elif cuts == 2:
        chunks = [lower[:,0:int(c/2)+pad,:],
                  lower[:,int(c/2)-pad:c,:],
                  upper[:,0:int(c/2)+pad,:],
                  upper[:,int(c/2)-pad:c,:]]
    
    return chunks
