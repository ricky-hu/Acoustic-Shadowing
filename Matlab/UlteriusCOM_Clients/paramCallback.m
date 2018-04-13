%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is a callback to respond to the paramEvent of the 
% UlteriusCOM server. It displays the Id of the parameter changed in the
% matlab environment
%
% Copyright: Ultrasonix Medical Corporation Jan 2013
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function paramCallback(varargin)

COM_Object_Sending_Event = varargin{1};

Event_ID        = varargin{2};
paramID         = varargin{3};
ptX             = varargin{4};
ptY             = varargin{5};
Event_Struct    = varargin{6};
Event_Name      = varargin{7};

display(['The following parameter was changed on the exam software: ' paramID]);