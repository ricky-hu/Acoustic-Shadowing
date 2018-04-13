% Converts post beam-formed RF data into pre scan-converted BMode
%
% Copyright - Ultrasonix Medical Corp
% Author: Ali Baghani, Nov 2012 based on
% readRFWriteEnv.m by Reza Zahiri Azar
function bm = rf2bmode(rf)

% decimation factor use to create Env from RF
decimationFactor = 4;

% make a compression table
alpha = 0.5;                % sqrt compression, change for a different compression table
denom = exp( alpha * log(65535) )/255.0;
CompressionTable = exp( alpha * log(0:65535) )/denom ; 

% calculate envelope and log compress
Env = 1 + fix(abs( hilbert( rf) ));
Env = CompressionTable(Env);

% decimate based on the decimation factor
EnvDec = decimate(Env(:, 1) , decimationFactor);
EnvDec = zeros(size(EnvDec, 1), size(rf, 2));
for i = 1:size(rf, 2)
    EnvDec(:,i) = decimate(Env(:,i) , decimationFactor);
end
% set the final value to be in this range [0 255]
EnvDec( find(EnvDec>255) ) = 255;

bm = EnvDec;
end
