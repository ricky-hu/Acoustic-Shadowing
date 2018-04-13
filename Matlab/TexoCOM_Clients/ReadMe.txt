The TexoCOM is a dll COM server which can be used to comminuicate with the Texo SDK from Matlab environment.

Dependencies:

- SonixDataTools which is a Matlab package for reading and visulaizing Sonix data.
- A 32 bit Matlab

The examples in this package:
- Acquire_RF_Data_From_Cine.m connects to Texo, programs the sequencer, acquires the data, reads the data stored in the cine, and dispalys them.
- Acquire_RF_Data_Real_Time.m connects to Texo, programs the sequencer, acquires the data in real-time and displays them.

To run the examples:
1. Make sure the TexoCOM.dll exists in the \bin folder of your SDK
2. Make sure the "addpath ..." lines in the code points to your SonixDataTools path
3. Make sure the "SDK_BIN_PATH ..." line in the code points to your SDK\bin folder
