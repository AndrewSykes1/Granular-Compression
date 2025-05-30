//-----------------------------------------------------------------//
// Name        | SC2_CamMatlab.h             | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Platform    | PC                                                //
//-----------------------------------------------------------------//
// Environment | Matlab                                            //
//-----------------------------------------------------------------//
// Purpose     | PCO - Matlab                                      //
//-----------------------------------------------------------------//
// Author      | MBL, PCO AG                                       //
//-----------------------------------------------------------------//
// Revision    |  rev. 1.10 rel. 1.10                              //
//-----------------------------------------------------------------//
// Notes       | Does include all necessary header files           //
//             |                                                   //
//             |                                                   //
//-----------------------------------------------------------------//
// (c) 2011 PCO AG * Donaupark 11 *                                //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: info@pco.de                 //
//-----------------------------------------------------------------//

#pragma pack(push)            
#pragma pack(1)            

#define MATLAB

#include "pco_matlab.h"

#define PCO_SENSOR_CREATE_OBJECT

#include "SC2_SDKAddendum.h"
#include "SC2_SDKStructures.h"
#include "SC2_defs.h"

#undef PCO_SENSOR_CREATE_OBJECT

typedef struct
{
  WORD          wSize;                 // Sizeof this struct
  WORD          wInterfaceType;        // 1: Firewire, 2: CamLink with Matrox, 3: CamLink with Silicon SW
  WORD          wCameraNumber;
  WORD          wCameraNumAtInterface; // Current number of camera at the interface
  WORD          wOpenFlags[10];        // [0]: moved to dwnext to position 0xFF00
                                       // [1]: moved to dwnext to position 0xFFFF0000
                                       // [2]: Bit0: PCO_OPENFLAG_GENERIC_IS_CAMLINK
                                       //            Set this bit in case of a generic Cameralink interface
                                       //            This enables the import of the additional three camera-
                                       //            link interface functions.

  DWORD         dwOpenFlags[5];        // [0]-[4]: moved to strCLOpen.dummy[0]-[4]
  void*         wOpenPtr1;
  void*         wOpenPtr2;
  void*         wOpenPtr3;
  void*         wOpenPtr4;
  void*         wOpenPtr5;
  void*         wOpenPtr6;
  WORD          zzwDummy[8];           // 88 - 64bit: 112
}PCO_OpenStruct;


typedef struct
{
  WORD                   BoardNum;       // number of devices
  PCO_SC2_Hardware_DESC  Board1;
  PCO_SC2_Hardware_DESC  Board2;
  PCO_SC2_Hardware_DESC  Board3;
  PCO_SC2_Hardware_DESC  Board4;
  PCO_SC2_Hardware_DESC  Board5;
  PCO_SC2_Hardware_DESC  Board6;
  PCO_SC2_Hardware_DESC  Board7;
  PCO_SC2_Hardware_DESC  Board8;
  PCO_SC2_Hardware_DESC  Board9;
  PCO_SC2_Hardware_DESC  Board10;
}
PCO_HW_Vers;

typedef struct
{
  WORD                   DeviceNum;       // number of devices
  PCO_SC2_Firmware_DESC  Device1;
  PCO_SC2_Firmware_DESC  Device2;
  PCO_SC2_Firmware_DESC  Device3;
  PCO_SC2_Firmware_DESC  Device4;
  PCO_SC2_Firmware_DESC  Device5;
  PCO_SC2_Firmware_DESC  Device6;
  PCO_SC2_Firmware_DESC  Device7;
  PCO_SC2_Firmware_DESC  Device8;
  PCO_SC2_Firmware_DESC  Device9;
  PCO_SC2_Firmware_DESC  Device10;
}
PCO_FW_Vers;

typedef struct
{
  WORD        wSize;                   // Sizeof this struct
  WORD        wCamType;                // Camera type
  WORD        wCamSubType;             // Camera sub type
  WORD        ZZwAlignDummy1;
  DWORD       dwSerialNumber;          // Serial number of camera // 12
  DWORD       dwHWVersion;             // Hardware version number
  DWORD       dwFWVersion;             // Firmware version number
  WORD        wInterfaceType;          // Interface type          // 22
  PCO_HW_Vers strHardwareVersion;      // Hardware versions of all boards // 644
  PCO_FW_Vers strFirmwareVersion;      // Firmware versions of all devices // 1286
  WORD        ZZwDummy[39];                                       // 1364
} PCO_CameraType;

typedef struct
{
  WORD        wSize;                   // Sizeof this struct
  WORD        ZZwAlignDummy1;
  PCO_CameraType strCamType;           // previous described structure // 1368
  DWORD       dwCamHealthWarnings;     // Warnings in camera system
  DWORD       dwCamHealthErrors;       // Errors in camera system
  DWORD       dwCamHealthStatus;       // Status of camera system      // 1380
  SHORT       sCCDTemperature;         // CCD temperature
  SHORT       sCamTemperature;         // Camera temperature           // 1384
  SHORT       sPowerSupplyTemperature; // Power device temperature
  WORD        ZZwDummy[37];                                            // 1460
} PCO_General;


typedef struct
{
  WORD        wSize;                     // Sizeof this struct
  WORD        ZZwAlignDummy1;                                             // 4
  PCO_Segment strSegment1;                // Segment info                  // 436
  PCO_Segment strSegment2;               // Segment info                  // 436
  PCO_Segment strSegment3;               // Segment info                  // 436
  PCO_Segment strSegment4;               // Segment info                  // 436
  PCO_Segment ZZstrDummySeg1;             // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg2;            // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg3;            // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg4;            // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg5;            // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg6;            // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg7;            // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg8;            // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg9;            // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg10;            // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg11;           // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg12;           // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg13;           // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg14;           // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg15;           // Segment info dummy            // 2164
  PCO_Segment ZZstrDummySeg16;           // Segment info dummy            // 2164
  WORD        wBitAlignment;             // Bitalignment during readout. 0: MSB, 1: LSB aligned
  WORD        wHotPixelCorrectionMode;   // Correction mode for hotpixel
  WORD        ZZwDummy[38];                                               // 2244
} PCO_Image;


typedef struct
{
  WORD  wSize;                         // Sizeof ‘this’ (for future enhancements)
  WORD  ZZwAlignDummy1;
  char  strSignalName1[25];            // Name of signal 104
  char  strSignalName2[25];            // Name of signal 104
  char  strSignalName3[25];            // Name of signal 104
  char  strSignalName4[25];            // Name of signal 104
  WORD wSignalDefinitions;             // Flags showing signal options
                                       // 0x01: Signal can be enabled/disabled
                                       // 0x02: Signal is a status (output)
                                       // Rest: future use, set to zero!
  WORD wSignalTypes;                   // Flags showing the selectability of signal types
                                       // 0x01: TTL
                                       // 0x02: High Level TTL
                                       // 0x04: Contact Mode
                                       // 0x08: RS485 diff.
                                       // Rest: future use, set to zero!
  WORD wSignalPolarity;                // Flags showing the selectability
                                       // of signal levels/transitions
                                       // 0x01: Low Level active
                                       // 0x02: High Level active
                                       // 0x04: Rising edge active
                                       // 0x08: Falling edge active
                                       // Rest: future use, set to zero!
  WORD wSignalFilter;                  // Flags showing the selectability of filter
                                       // settings
                                       // 0x01: Filter can be switched off (t > ~65ns)
                                       // 0x02: Filter can be switched to medium (t > ~1us)
                                       // 0x04: Filter can be switched to high (t > ~100ms) 112
  DWORD dwDummy[22];                   // reserved for future use. (only in SDK) 200
}PCO_Single_Signal_Desc;


typedef struct
{
  WORD              wSize;             // Sizeof ‘this’ (for future enhancements)
  WORD              wNumOfSignals;     // Parameter to fetch the num. of descr. from the camera
  PCO_Single_Signal_Desc strSingeSignalDesc1;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc2;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc3;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc4;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc5;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc6;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc7;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc8;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc9;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc10;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc11;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc12;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc13;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc14;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc15;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc16;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc17;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc18;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc19;// Array of singel signal descriptors // 4004
  PCO_Single_Signal_Desc strSingeSignalDesc20;// Array of singel signal descriptors // 4004
  DWORD             dwDummy[524];      // reserved for future use.    // 6100
} PCO_Signal_Description;

typedef struct
{
  WORD        wSize;                   // Sizeof this struct
  WORD        ZZwAlignDummy1;
  PCO_Description strDescription;      // previous described structure // 440
  PCO_Description2 strDescription2;    // second descriptor            // 736
  DWORD       ZZdwDummy2[256];         //                              // 1760
  WORD        wSensorformat;           // Sensor format std/ext
  WORD        wRoiX0;                  // Roi upper left x
  WORD        wRoiY0;                  // Roi upper left y
  WORD        wRoiX1;                  // Roi lower right x
  WORD        wRoiY1;                  // Roi lower right y            // 1770
  WORD        wBinHorz;                // Horizontal binning
  WORD        wBinVert;                // Vertical binning
  WORD        ZZwAlignDummy2;
  DWORD       dwPixelRate;             // 32bit unsigend, Pixelrate in Hz: // 1780
                                       // depends on descriptor values
  WORD        wConvFact;               // Conversion factor:
                                       // depends on descriptor values
  WORD        wDoubleImage;            // Double image mode
  WORD        wADCOperation;           // Number of ADCs to use
  WORD        wIR;                     // IR sensitivity mode
  SHORT       sCoolSet;                // Cooling setpoint             // 1790
  WORD        wOffsetRegulation;       // Offset regulation mode       // 1792
  WORD        wNoiseFilterMode;        // Noise filter mode
  WORD        wFastReadoutMode;        // Fast readout mode for dimax
  WORD        wDSNUAdjustMode;         // DSNU Adjustment mode
  WORD        wCDIMode;                // Correlated double image mode // 1800
  WORD        ZZwDummy[36];                                            // 1872
  PCO_Signal_Description strSignalDesc;// Signal descriptor            // 7972
  DWORD       ZZdwDummy[PCO_SENSORDUMMY];                              // 8000
} PCO_Sensor;


typedef struct
{
  WORD        wSize;                   // Sizeof this struct
  WORD        wTimeBaseDelay;          // Timebase delay 0:ns, 1:µs, 2:ms
  WORD        wTimeBaseExposure;       // Timebase expos 0:ns, 1:µs, 2:ms
  WORD        ZZwAlignDummy1;                                             // 8
  DWORD       ZZdwDummy0[2];           // removed single entry for dwDelay and dwExposure // 16
  DWORD       dwDelayTable[PCO_MAXDELEXPTABLE];// Delay table             // 80
  DWORD       ZZdwDummy1[114];                                            // 536
  DWORD       dwExposureTable[PCO_MAXDELEXPTABLE];// Exposure table       // 600
  DWORD       ZZdwDummy2[112];                                            // 1048
  WORD        wTriggerMode;            // Trigger mode                    // 1050
                                       // 0: auto, 1: software trg, 2:extern 3: extern exp. ctrl
  WORD        wForceTrigger;           // Force trigger (Auto reset flag!)
  WORD        wCameraBusyStatus;       // Camera busy status 0: idle, 1: busy
  WORD        wPowerDownMode;          // Power down mode 0: auto, 1: user // 1056
  DWORD       dwPowerDownTime;         // Power down time 0ms...49,7d     // 1060
  WORD        wExpTrgSignal;           // Exposure trigger signal status
  WORD        wFPSExposureMode;        // Cmos-Sensor FPS exposure mode
  DWORD       dwFPSExposureTime;       // Resulting exposure time in FPS mode // 1068

  WORD        wModulationMode;         // Mode for modulation (0 = modulation off, 1 = modulation on) // 1070
  WORD        wCameraSynchMode;        // Camera synchronisation mode (0 = off, 1 = master, 2 = slave)
  DWORD       dwPeriodicalTime;        // Periodical time (unit depending on timebase) for modulation // 1076
  WORD        wTimeBasePeriodical;     // timebase for periodical time for modulation  0 -> ns, 1 -> µs, 2 -> ms
  WORD        ZZwAlignDummy3;
  DWORD       dwNumberOfExposures;     // Number of exposures during modulation // 1084
  LONG        lMonitorOffset;          // Monitor offset value in ns      // 1088
  PCO_Signal  strSignal1;               // Signal settings               // 2288
  PCO_Signal  strSignal2;               // Signal settings               // 2288
  PCO_Signal  strSignal3;               // Signal settings               // 2288
  PCO_Signal  strSignal4;               // Signal settings               // 2288
  PCO_Signal  strSignal5;               // Signal settings               // 2288
  PCO_Signal  strSignal6;               // Signal settings               // 2288
  PCO_Signal  strSignal7;               // Signal settings               // 2288
  PCO_Signal  strSignal8;               // Signal settings               // 2288
  PCO_Signal  strSignal9;               // Signal settings               // 2288
  PCO_Signal  strSignal10;               // Signal settings               // 2288
  PCO_Signal  strSignal11;               // Signal settings               // 2288
  PCO_Signal  strSignal12;               // Signal settings               // 2288
  PCO_Signal  strSignal13;               // Signal settings               // 2288
  PCO_Signal  strSignal14;               // Signal settings               // 2288
  PCO_Signal  strSignal15;               // Signal settings               // 2288
  PCO_Signal  strSignal16;               // Signal settings               // 2288
  PCO_Signal  strSignal17;               // Signal settings               // 2288
  PCO_Signal  strSignal18;               // Signal settings               // 2288
  PCO_Signal  strSignal19;               // Signal settings               // 2288
  PCO_Signal  strSignal20;               // Signal settings               // 2288
  WORD        wStatusFrameRate;        // Framerate status
  WORD        wFrameRateMode;          // Dimax: Mode for frame rate
  DWORD       dwFrameRate;             // Dimax: Framerate in mHz
  DWORD       dwFrameRateExposure;     // Dimax: Exposure time in ns      // 2300
  WORD        wTimingControlMode;      // Dimax: Timing Control Mode: 0->Exp./Del. 1->FPS
  WORD        wFastTimingMode;         // Dimax: Fast Timing Mode: 0->off 1->on
  WORD        ZZwDummy[PCO_TIMINGDUMMY];                                               // 2352
} PCO_Timing;



typedef struct
{
  WORD          wSize;                 // Sizeof this struct
  WORD          wCameraNum;            // Current number of camera
  HANDLE        hCamera;               // Handle of the device
  WORD          wTakenFlag;            // Flags to show whether the device is taken or not. // 10
  WORD          ZZwAlignDummy1;                                                             // 12
  void*         pSC2IFFunc1;           // functions  [20];                                  // 92
  void*         pSC2IFFunc2;
  void*         pSC2IFFunc3;
  void*         pSC2IFFunc4;
  void*         pSC2IFFunc5;
  void*         pSC2IFFunc6;
  void*         pSC2IFFunc7;
  void*         pSC2IFFunc8;
  void*         pSC2IFFunc9;
  void*         pSC2IFFunc10;
  void*         pSC2IFFunc11;
  void*         pSC2IFFunc12;
  void*         pSC2IFFunc13;
  void*         pSC2IFFunc14;
  void*         pSC2IFFunc15;
  void*         pSC2IFFunc16;
  void*         pSC2IFFunc17;
  void*         pSC2IFFunc18;
  void*         pSC2IFFunc19;
  void*         pSC2IFFunc20;
          
  PCO_APIBuffer strPCOBuf1;            // Bufferlist [PCO_BUFCNT]; 16                       // 892
  PCO_APIBuffer strPCOBuf2;            
  PCO_APIBuffer strPCOBuf3;            
  PCO_APIBuffer strPCOBuf4;            
  PCO_APIBuffer strPCOBuf5;            
  PCO_APIBuffer strPCOBuf6;            
  PCO_APIBuffer strPCOBuf7;            
  PCO_APIBuffer strPCOBuf8;            
  PCO_APIBuffer strPCOBuf9;            
  PCO_APIBuffer strPCOBuf10;            
  PCO_APIBuffer strPCOBuf11;            
  PCO_APIBuffer strPCOBuf12;            
  PCO_APIBuffer strPCOBuf13;            
  PCO_APIBuffer strPCOBuf14;            
  PCO_APIBuffer strPCOBuf15;            
  PCO_APIBuffer strPCOBuf16;            
  PCO_APIBuffer ZZstrDummyBuf1;         // Bufferlist [28-PCO_BUFCNT] 28-16=12              // 2892
  PCO_APIBuffer ZZstrDummyBuf2;         
  PCO_APIBuffer ZZstrDummyBuf3;         
  PCO_APIBuffer ZZstrDummyBuf4;         
  PCO_APIBuffer ZZstrDummyBuf5;         
  PCO_APIBuffer ZZstrDummyBuf6;         
  PCO_APIBuffer ZZstrDummyBuf7;         
  PCO_APIBuffer ZZstrDummyBuf8;         
  PCO_APIBuffer ZZstrDummyBuf9;         
  PCO_APIBuffer ZZstrDummyBuf10;         
  PCO_APIBuffer ZZstrDummyBuf11;         
  PCO_APIBuffer ZZstrDummyBuf12;         
  SHORT         sBufferCnt;            // Index for buffer allocation
  WORD          wCameraNumAtInterface; // Current number of camera at the interface
  WORD          wInterface;            // Interface type (used before connecting to camera)
                                       // different from PCO_CameraType (!)
  WORD          wXRes;                 // X Resolution in Grabber (CamLink only)            // 2900
  WORD          wYRes;                 // Y Resolution in Buffer (CamLink only)             // 2902
  WORD          ZZwAlignDummy2;
  DWORD         dwIF_param[5];         // Interface specific parameter                      // 2924
                                       // 0 (FW:bandwidth or CL:baudrate ) 
                                       // 1 (FW:speed     or CL:clkfreq  ) 
                                       // 2 (FW:channel   or CL:ccline   ) 
                                       // 3 (FW:buffer    or CL:data     ) 
                                       // 4 (FW:iso_bytes or CL:transmit ) 
  WORD          ZZwDummy[26];                                                               // 2976
} PCO_APIManagement;

typedef struct
{
  WORD              wSize;             // Sizeof this struct
  WORD              wStructRev;        // internal parameter, must be set to PCO_STRUCTDEF
  PCO_General       strGeneral;
  PCO_Sensor        strSensor;
  PCO_Timing        strTiming;
  PCO_Storage       strStorage;
  PCO_Recording     strRecording;
  PCO_Image         strImage;
  PCO_APIManagement strAPIManager;
  WORD              ZZwDummy[40];
} PCO_Camera;                          // 17404


#include "SC2_CamExport.h"

#pragma pack(pop)            



