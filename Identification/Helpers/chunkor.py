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

    # region Space Details
    # Make sure data is evenly divisable
    assert all(coord % 2 == 0 for coord in data.shape), 'Data dimensions must all be even.' 

    # Identify device for cut count
    device = torch.cuda.get_device_name()
    if device == 'NVIDIA RTX A2000 12GB':
        client = 'Desktop'
        cuts = 2
    elif device == 'NVIDIA RTX 4000 Ada Generation':
        client = 'Server'
        cuts = 1

    # Find info on current gpu usage
    info = [torch.cuda.get_device_properties(0).total_memory,
            torch.cuda.memory_reserved(0),
            torch.cuda.memory_allocated(0)]
    df = pd.DataFrame([np.round(item/(1024**3),2) for item in info],
                       index=['Total','Reserved','Allocated'],columns=['VRam'])

    # Print GPU and server details
    print(f'{client} device detected: {device}')
    print(f'Data Ram: {np.round(data.nbytes/(1024**3),2)} GB')
    print(f'Attempting {2**cuts} partitions')
    display(df)
    #endregion

    # Define cuts and pads
    r,c,z = data.shape
    kP = int(kernel.shape[0]/2) # Announce padding needed to prevent circular conv

    upper = data[:,:,   int(z/2)-kP: ] # U
    lower = data[:,:, 0:int(z/2)+kP  ] # L
    
    # Save cut segments to list
    if cuts==1:
        upperP = np.pad(upper, pad_width=((kP,kP),(kP,kP),(0,kP)))
        lowerP = np.pad(lower, pad_width=((kP,kP),(kP,kP),(kP,0)))
        chunksP = [upperP,lowerP]

    elif cuts == 2:
        uu,ul = upper[:, :int(c/2)+kP ,:], upper[:, int(c/2)-kP: ,:]
        lu,ll = lower[:, :int(c/2)+kP ,:], lower[:, int(c/2)-kP: ,:]
        
        uuP = np.pad(uu,pad_width=((),(),()))


        chunks = [upper[:, int(c/2)+kP ,:], upper[:, 0:int(c/2)-kP ,:], #UU, UL
                  lower[:, int(c/2)+kP ,:], lower[:, 0:int(c/2)-kP ,:]] #LU, LL
    


    # Apply global padding to chunks
    print(chunks[0].shape)
    pchunks = [F.pad(torch.from_numpy(chunk), pad=(pads,)*6) for chunk in chunks]
    
    # Create padding around kernel to match size of globally padded chunks
    padding = tuple([[pchunks[0].numpy().shape[int(i/2)]-kernel.shape[int(i/2)] if i % 2 == 0 else 0 for i in range(6)][i] for i in [4,5,2,3,0,1]])
    pkernel =  F.pad(torch.from_numpy(kernel), pad=padding)
    print(pchunks[0].shape)

    return pchunks, pkernel, cuts
