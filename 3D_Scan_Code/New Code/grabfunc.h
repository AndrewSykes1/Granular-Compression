#include "shrhelp.h"

#include "matrix.h"
/*#include "mex.h"*/

EXPORTED_FUNCTION void showhandle(void *hcam);

EXPORTED_FUNCTION void pco_edge_transferpar(void *hcam);

EXPORTED_FUNCTION mxArray* pco_imagestack(unsigned short *num,void *hcam,int addfirst);
