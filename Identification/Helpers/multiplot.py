import matplotlib.pyplot as plt

def multiplot(*args, plots=None, size=(7,7), color='grey', titles=None, ax_vis=False, tight=True):
    """
    Creates a subplot of a set of images
    
    :param args: Any number of input 2d images
    :param plots: List of 1st element describing number of rows, 2nd describing number of columns
    :param size: Tuple describing the figsize desired
    :param color: Cmap of figure
    :param titles: List of titles to include for each image
    :param ax_vis: Whether or not to display axis
    :param tight: Whether or not to use fig.tight_layout() and remove whitespace

    Example:
        >>> multiplot(img1,img2)
        >>> multiplot(img1,img2, size = (10,2))
        >>> multiplot(img1,img2,img3,img4, plots=(2,2)
    """

    # Set figure grid size
    rows,cols = 1,len(args)
    if plots != None:
        rows,cols = plots
            
    # Create subplots and set settings
    fig, axs = plt.subplots(nrows=rows,ncols=cols,figsize=size)
    axs = axs.ravel()
    for i,img in enumerate(args):
        axs[i].imshow(img,cmap=color)
        if titles != None:
            axs[i].set_title(titles[i])
        if ax_vis == False:
            axs[i].axis('off')
    fig.tight_layout()

    plt.show()


