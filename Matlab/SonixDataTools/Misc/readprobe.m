%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function reads the probe parameters from the probe.xml file based on
% the probe id provided.
%
% Copyright: Ultrasonix Medical Corporation Nov 2012
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Probe = readprobe(fileName, probeID);

% Open the probes.xml file and read it into mem
fid = fopen(fileName, 'r');
if (fid == -1)
    errordlg({'Could not find the probes.xml file in here:', fileName}, 'modal');
    Probe = [];
    return;
end
Exp = fread(fid,'char');
Exp = char(Exp.');
fclose(fid);

% Since matlab search is greedy, we cannot use a single regex
% finding the probe id in the file
startI = regexp(Exp, ['<probe *id= *" *',num2str(probeID),' *"']);
if isempty(startI)
    Probe = [];
    return;
end
endI = regexp(Exp(startI:end), '</probe>');
endI = endI(1);
% Picking out the text relating to the probe
Exp = Exp(startI:startI+endI+6);

% Extracting the biopsy parameters
startI    = regexp(Exp,'<biopsy>.*</biopsy>','start');
endI      = regexp(Exp,'<biopsy>.*</biopsy>','end');
BiopsyExp = Exp(startI:endI);
Exp(startI:endI) = [];
Probe.biopsy = BiopsyExp;


% Extracting the vendors parameters
startI    = regexp(Exp,'<vendors>.*</vendors>','start');
endI      = regexp(Exp,'<vendors>.*</vendors>','end');
VendorExp = Exp(startI:endI);
Exp(startI:endI) = [];
Probe.vendors = VendorExp;

% Extracting the type
tempExp = regexp(Exp,'<type>\d*</type>','match');
tempExp = regexp(tempExp{1},'\d*','match');
Probe.type = str2num(tempExp{1});

% Extracting the transmitoffset
tempExp = regexp(Exp,'<transmitoffset>[\d\.]*</transmitoffset>','match');
tempExp = regexp(tempExp{1},'[\d\.]*','match');
Probe.transmitoffset = str2num(tempExp{1});

% Extracting the frequency parameters
startI   = regexp(Exp,'<frequency>.*</frequency>','start');
endI     = regexp(Exp,'<frequency>.*</frequency>','end');
FreqExp  = Exp(startI:endI);
Exp(startI:endI) = [];
        % center
        tempExp = regexp(FreqExp,'<center>\d*</center>','match');
        tempExp = regexp(tempExp{1},'\d*','match');
        Probe.frequency.center = str2num(tempExp{1});
        % bandwidth
        tempExp = regexp(FreqExp,'<bandwidth>\d*</bandwidth>','match');
        tempExp = regexp(tempExp{1},'\d*','match');
        Probe.frequency.bandwidth = str2num(tempExp{1});

% Extracting the maxfocusdistance
tempExp = regexp(Exp,'<maxfocusdistance>\d*</maxfocusdistance>','match');
tempExp = regexp(tempExp{1},'\d*','match');
Probe.maxfocusdistance = str2num(tempExp{1});

% Extracting the number of elements
tempExp = regexp(Exp,'<maxsteerangle>\d*</maxsteerangle>','match');
tempExp = regexp(tempExp{1},'\d*','match');
Probe.maxsteerangle = str2num(tempExp{1});

% Extracting the minFocusDistanceDoppler
tempExp = regexp(Exp,'<minFocusDistanceDoppler>\d*</minFocusDistanceDoppler>','match');
tempExp = regexp(tempExp{1},'\d*','match');
Probe.minFocusDistanceDoppler = str2num(tempExp{1});

% Extracting the number of elements
tempExp = regexp(Exp,'<minlineduration>\d*</minlineduration>','match');
tempExp = regexp(tempExp{1},'\d*','match');
Probe.minlineduration = str2num(tempExp{1});

% Extracting the motor parameters
startI   = regexp(Exp,'<motor>.*</motor>','start');
endI     = regexp(Exp,'<motor>.*</motor>','end');
MotorExp = Exp(startI:endI);
Exp(startI:endI) = [];
        % FOV
        tempExp = regexp(MotorExp,'<FOV>\d*</FOV>','match');
        tempExp = regexp(tempExp{1},'\d*','match');
        Probe.motor.FOV = str2num(tempExp{1});
        % homeMethod
        tempExp = regexp(MotorExp,'<homeMethod>\d*</homeMethod>','match');
        tempExp = regexp(tempExp{1},'\d*','match');
        Probe.motor.homeMethod = str2num(tempExp{1});
        % minTimeBetweenPulses
        tempExp = regexp(MotorExp,'<minTimeBetweenPulses>\d*</minTimeBetweenPulses>','match');
        tempExp = regexp(tempExp{1},'\d*','match');
        Probe.motor.minTimeBetweenPulses = str2num(tempExp{1});
        % radius
        tempExp = regexp(MotorExp,'<radius>\d*</radius>','match');
        tempExp = regexp(tempExp{1},'\d*','match');
        Probe.motor.radius = str2num(tempExp{1});
        % steps
        tempExp = regexp(MotorExp,'<steps>\d*</steps>','match');
        tempExp = regexp(tempExp{1},'\d*','match');
        Probe.motor.steps = str2num(tempExp{1});
        % homeCorrection
        tempExp = regexp(MotorExp,'<homeCorrection>\d*</homeCorrection>','match');
        tempExp = regexp(tempExp{1},'\d*','match');
        Probe.motor.homeCorrection = str2num(tempExp{1});
       
        
% Extracting the probe name
tempExp = regexp(Exp,'<probe *id[^>]*>','match');
tempExp = regexp(tempExp{1},'name=".*"','match');
tempExp = regexp(tempExp{1},'".*"','match');
Probe.name = tempExp{1}(2:end-1);

% Extracting the number of elements
tempExp = regexp(Exp,'<numElements>\d*</numElements>','match');
tempExp = regexp(tempExp{1},'\d*','match');
Probe.numElements = str2num(tempExp{1});

% Extracting the probe pinOffset
tempExp = regexp(Exp,'<pinOffset>\d*</pinOffset>','match');
tempExp = regexp(tempExp{1},'\d*','match');
Probe.pinOffset = str2num(tempExp{1});

% Extracting the element pitch
tempExp = regexp(Exp,'<pitch>\d*</pitch>','match');
tempExp = regexp(tempExp{1},'\d*','match');
Probe.pitch = str2num(tempExp{1});

% Extracting the probe radius
tempExp = regexp(Exp,'<radius>\d*</radius>','match');
tempExp = regexp(tempExp{1},'\d*','match');
Probe.radius = str2num(tempExp{1});

% Extracting the support parameters
startI   = regexp(Exp,'<support>.*</support>','start');
endI     = regexp(Exp,'<support>.*</support>','end');
SupportExp = Exp(startI:endI);
Exp(startI:endI) = [];
Probe.support = SupportExp;

% Extracting the muxWrap
startI   = regexp(Exp,'<muxWrap>.*</muxWrap>','start');
endI     = regexp(Exp,'<muxWrap>.*</muxWrap>','end');
MuxWrapExp = Exp(startI:endI);
Exp(startI:endI) = [];
Probe.muxWrap = MuxWrapExp;

% Extracting the probe elevationLength
tempExp = regexp(Exp,'<elevationLength>[\d\.]*</elevationLength>','match');
tempExp = regexp(tempExp{1},'[\d\.]*','match');
Probe.elevationLength = str2num(tempExp{1});


% Extracting the probe maxPwPrp
tempExp = regexp(Exp,'<maxPwPrp>\d*</maxPwPrp>','match');
tempExp = regexp(tempExp{1},'\d*','match');
Probe.maxPwPrp = str2num(tempExp{1});


% Extracting the probe invertedElements
tempExp = regexp(Exp,'<invertedElements>\d*</invertedElements>','match');
tempExp = regexp(tempExp{1},'\d*','match');
Probe.invertedElements = str2num(tempExp{1});



  
