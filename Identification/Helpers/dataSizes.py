import numpy as np
import pandas as pd

def dataSizes(vars, type=np.ndarray):
    """
    Creates a pandas dataframe to display sizes of objects matching a datatype in Mb and Gb

    :param vars: Default output of globals().items()
    :param type: Data type to be displayed, default looks for arrays

    Examples:
        >>> dataSizes(globals().items(), type=np.int64)
    """

    sizeInfo = {name:obj.nbytes for name,obj in vars
            if not name.startswith('_') and isinstance(obj,type)}
    sizeInfo = dict(sorted(sizeInfo.items(), key=lambda x: x[1], reverse=True))
    
    sizes = {'Mb':[f'{sizeInfo[name]/(1024**2):.0f}' for name in sizeInfo.keys()],
            'Gb':[f'{sizeInfo[name]/(1024**3):.1f}' for name in sizeInfo.keys()]}

    return pd.DataFrame(sizes,index=sizeInfo.keys())
    