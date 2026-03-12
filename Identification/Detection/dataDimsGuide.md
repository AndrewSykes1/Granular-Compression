# Data Dimensions
Although the dimensions of the incoming data may seem like any set would do, due to the FFT transforms, padding, and kernel sizes requiring certain attributes the dimensions of the incoming data are nescessary to be fine tuned and this short manual describes what to do and why.

First you must figure out what **GPU** your data is going to be processed on.
- If you are working on the server, your data will be divided into 2 chunks along the z axis.
- If you are working on the desktop, your data will be divided into 4 chunks cut by the z axis, and the c axis both in half.

All other uncut data dims must be odd.

Knowing this info, you must assure 2 things. Namely, the axis that you divide by must be divisable by 4. This is because we want an odd data size by the time we do fft so we can scale up the kernel symmetrically via adding an even amount of padding. Assymmetric kernels decrease our accuracy in convolution or create a shift I do not want to account for.

So for example if you are working on the desktop, you will want perhaps the following size: (19,19,24), but the size (19,19,20) would not be acceptable.

Next your kernel size length and thus the kernel padding must be odd. This *should* be done automatically and consistently, but since the user has some control over the kernel dimensions I figure it is worth noting to not mess it up.

If all of these ideas are fulfilled, the data processing should run smoothly, to summarize them I have a list of the following. (Additionally there should be assert statements to make sure of these things but I don't do pytest)

### Requirements:
- Data dimensions must be odd
- If on desktop, z axis and c axis must be divisable by 4
- If on server, z axis must be divisable by 4
- Kernel size must be odd in all dimensions
- Padding size must be odd