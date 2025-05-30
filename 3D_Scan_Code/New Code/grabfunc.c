/*==========================================================
 * camtest.c - example in MATLAB External Interfaces
 *
 * calling function from cameralib
 * here matrix with sizes is returned 
 *
 * The calling syntax is:
 *
 *		outMatrix = camtest(camHandle)
 *
 * This is a MEX-file for MATLAB.
 * Copyright 2007-2008 The MathWorks, Inc.
 *
 *========================================================*/
/* $Revision: 1.1.10.2 $ */

#include "windows.h"

#include "mex.h"

#define EXPORT_FCNS
#include "shrhelp.h"

#include "SC2_SDKAddendum.h"
#include "SC2_SDKStructures.h"
#include "SC2_defs.h"
#include "SC2_CamExport.h"

/* The computational routine */

EXPORTED_FUNCTION void showhandle(void *hcam)
{
   DWORD err; 
   WORD wXResAct,wYResAct,wXResMax,wYResMax;
   
   wXResAct=wYResAct=wXResMax=wYResMax=0;
   
   mexPrintf("show handle %p\n",hcam);   

   err=PCO_GetSizes(hcam,&wXResAct,&wYResAct,&wXResMax,&wYResMax);
   if(err!=0)
    mexPrintf("\nPCO_GetSizes returned error 0x%x\n",err);
   
   mexPrintf("sizes are act: %dx%d ccd %dx%d\n",wXResAct,wYResAct,wXResMax,wYResMax);   
}


EXPORTED_FUNCTION void pco_edge_transferpar(void *hcam)
{
   DWORD err; 
   WORD wXResAct,wYResAct,wXResMax,wYResMax;
   DWORD dwPixelRate;
   PCO_SC2_CL_TRANSFER_PARAM clpar;
   WORD wRec_state,wId,wPar;
   
   wXResAct=wYResAct=wXResMax=wYResMax=0;
   
   err=PCO_GetSizes(hcam,&wXResAct,&wYResAct,&wXResMax,&wYResMax);
   if(err!=0)
    mexPrintf("\nPCO_GetSizes returned error 0x%x\n",err);

   mexPrintf("sizes are act: %dx%d ccd %dx%d\n",wXResAct,wYResAct,wXResMax,wYResMax);   
   
   err=PCO_GetPixelRate(hcam,&dwPixelRate);
   if(err!=0)
    mexPrintf("\nPCO_GetPixelRate returned error 0x%x\n",err);
   
   err=PCO_GetTransferParameter(hcam,&clpar,sizeof(clpar));
   if(err!=0)
    mexPrintf("\nPCO_GetTransferParameter returned error 0x%x\n",err);
   
   mexPrintf("actual transfer parameter:\n");
   mexPrintf("Baudrate       : %d\n",clpar.baudrate); 
   mexPrintf("Clockfrequency : %d\n",clpar.ClockFrequency); 
   mexPrintf("Dataformat     : 0x%x\n",clpar.DataFormat); 
   mexPrintf("Transmit       : 0x%x\n",clpar.Transmit); 

   
   if((dwPixelRate<100000000)||(wXResAct<=1920))
   {
    clpar.DataFormat&=~PCO_CL_DATAFORMAT_MASK;
    clpar.DataFormat|=PCO_CL_DATAFORMAT_5x16;
    wId=wPar=0;
   }
   else
   {
    clpar.DataFormat&=~PCO_CL_DATAFORMAT_MASK;
    clpar.DataFormat|=PCO_CL_DATAFORMAT_5x12;
    wPar=0;
    wId=0x1612;
   }   
   
   err=PCO_GetRecordingState(hcam,&wRec_state);
   if(err!=0)
    mexPrintf("\nPCO_GetRecordingState returned error 0x%x\n",err);
   if(wRec_state!=0)
   {
    err=PCO_SetRecordingState(hcam,0);
    if(err!=0)
     mexPrintf("\nPCO_SetRecordingState returned error 0x%x\n",err);
   }
   
   err=PCO_SetActiveLookupTable(hcam,&wId,&wPar);
   if(err!=0)
    mexPrintf("\nPCO_SetActiveLookupTable returned error 0x%x\n",err);
   
   err=PCO_SetTransferParameter(hcam,&clpar,sizeof(clpar));
   if(err!=0)
    mexPrintf("\nPCO_SetTransferParameter returned error 0x%x\n",err);

   err=PCO_ArmCamera(hcam);
   if(err!=0)
    mexPrintf("\nPCO_ArmCamera returned error 0x%x\n",err);

   if(wRec_state!=0)
   {
    err=PCO_SetRecordingState(hcam,wRec_state);
    if(err!=0)
     mexPrintf("\nPCO_SetRecordingState returned error 0x%x\n",err);
   }

   err=PCO_GetTransferParameter(hcam,&clpar,sizeof(clpar));
   if(err!=0)
    mexPrintf("\nPCO_GetTransferParameter returned error 0x%x\n",err);
   
   mexPrintf("actual transfer parameter:\n");
   mexPrintf("Baudrate       : %d\n",clpar.baudrate); 
   mexPrintf("Clockfrequency : %d\n",clpar.ClockFrequency); 
   mexPrintf("Dataformat     : 0x%x\n",clpar.DataFormat); 
   mexPrintf("Transmit       : 0x%x\n",clpar.Transmit); 
   
}

#define IMADIM 2
#define IMASTACKDIM 3
#define BUFNUM 4

EXPORTED_FUNCTION mxArray* pco_imagestack(unsigned short *num,void *hcam,int addfirst)
{
 mxArray* ima_stack;
 mwSize dims[IMASTACKDIM];
 mwSize x,y,z;
 WORD wXResAct,wYResAct,wXResMax,wYResMax;
 WORD *data, *pdat;
 WORD act_recstate;
 WORD *bufadr[BUFNUM];
 HANDLE hevent[BUFNUM];
 DWORD dwStatus[BUFNUM];
 DWORD retval;
 int bufnr,nr_of_buffer;
 
 int size,err;
 
 wXResAct=20;
 wYResAct=5;
 wXResMax=wYResMax=0;

 err=PCO_GetSizes(hcam,&wXResAct,&wYResAct,&wXResMax,&wYResMax);
 if(err!=0)
 { 
  mexPrintf("\nPCO_GetSizes returned error 0x%x\n",err);
  return NULL;
 }

 dims[0]=wXResAct;
 dims[1]=wYResAct;
 dims[2]=*num;

 size=wXResAct*wYResAct;
 
 ima_stack=mxCreateNumericArray(IMASTACKDIM,dims,mxUINT16_CLASS,mxREAL); 
 if(ima_stack==NULL)
 {
  mexPrintf("\nCould not allocate array for %d images of size %dx%d\n",(int)dims[3],(int)dims[0],(int)dims[1]);
  *num=0;
  return NULL;
 }       
 data=mxGetData(ima_stack);
 pdat=data;

 if(dims[2]<BUFNUM)
  nr_of_buffer=dims[2];
 else
  nr_of_buffer=BUFNUM;

 //only to create events without using windows
 for(x=0;x<nr_of_buffer;x++)
 {
  hevent[x]=CreateEvent(0,TRUE,FALSE,NULL);;   
  bufadr[x]=pdat;
  pdat+=size;
 }
         
 err=PCO_GetRecordingState(hcam,&act_recstate);
 if(err!=0)
  mexPrintf("\nPCO_GetRecordingState returned error 0x%x\n",err);
 
 if(act_recstate==0)
 {
  err=PCO_ArmCamera(hcam);
  if(err!=0)
   mexPrintf("\nPCO_ArmCamera returned error 0x%x\n",err);
     
  if(addfirst==0)
  {
   err=PCO_SetRecordingState(hcam,1);
   if(err!=0)
    mexPrintf("\nPCO_SetRecordingState returned error 0x%x\n",err);
  }
 }

 for(x=0;x<nr_of_buffer;x++)
 {
  err=PCO_AddBufferExtern(hcam,hevent[x],1,0,0,0,bufadr[x],size*sizeof(WORD),&dwStatus[x]);
  if(err!=0)
   mexPrintf("\nPCO_AddBufferExtern returned error 0x%x\n",err);
 }     

 if((act_recstate==0)&&(addfirst==1))
 {
  err=PCO_SetRecordingState(hcam,1);
  if(err!=0)
   mexPrintf("\nPCO_SetRecordingState returned error 0x%x\n",err);
 }
 
 for(z=0;z<dims[2];z++)
 {
  retval=WaitForMultipleObjects(nr_of_buffer,hevent,FALSE,10000);
  switch(retval)
  {
   default:
   {
    bufnr=retval-WAIT_OBJECT_0;
    mexPrintf("image %d buffer %d event set, status is 0x%x\n",z+1,bufnr,dwStatus[bufnr]);
	ResetEvent(hevent[bufnr]);
    if((dwStatus[bufnr]==0)&&((z+nr_of_buffer)<dims[2]))
    {
     bufadr[bufnr]=pdat;   
     pdat+=size;
     err=PCO_AddBufferExtern(hcam,hevent[bufnr],1,0,0,0,bufadr[bufnr],size*sizeof(WORD),&dwStatus[bufnr]);
     if(err!=0)
      mexPrintf("\nPCO_AddBufferExtern returned error 0x%x\n",err);
    }
   }
   break;

   case WAIT_TIMEOUT:
   {
    mexPrintf("\n Timeout or other error waiting for buffer break loop");
    break;
   }
  }
 }
 
 if(act_recstate==0)
 {
  err=PCO_SetRecordingState(hcam,0);
  if(err!=0)
   mexPrintf("\nPCO_SetRecordingState returned error 0x%x\n",err);
 }
 
 for(x=0;x<nr_of_buffer;x++)
 {
  CloseHandle(hevent[x]);
 }

 return ima_stack; 
}



/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
}
