The UlteriusCOM is a dll COM server which can be used to comminuicate with the Ultrerius SDK from Matlab environment.

Dependencies:

- SonixDataTools which is a Matlab package for reading and visulaizing Sonix data.
- A 32 bit Matlab

The examples in this package:
- Acquire_Images_From_Cine.m connects to the Exam software and reads the data in the Cine.
- Acquire_Images_Real_Time.m connects to the Exam software and acquires data in real time.
- Acquire_Images_Real_Time_Injection.m connects to the Exam software and acquires data in real time and injects it back into the exam software.

To run the examples:
1. Make sure the UlteriusCOM.dll exists in the \bin folder of your SDK
2. Make sure the "addpath ..." lines in the code points to your SonixDataTools path
3. Make sure the "SDK_BIN_PATH ..." line in the code points to your SDK\bin folder
4. Change the "SONIX_IP ..." to reflect the IP address of the Sonix machine on which the hardware is installed and the exam software is running.