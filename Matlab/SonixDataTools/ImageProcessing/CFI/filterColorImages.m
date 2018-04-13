function [vel, pow, sig] = filterColorImages(vel, pow, sig, velC, powC, sigC)
% The following script filtered the velocity, power, and sigma images based
% on the predefined threshold values.
%
% Copyright Ultrasonix Medical corporation
% Author: Reza Zahiri Azar - July 2010

% filter settings
% Note: this values need to be optimized for different settings
powerMin = 10;   % dB
powerMaxClutter = 140; %dB

% set to zero
vel( pow< powerMin ) = 0;
vel( powC> powerMaxClutter ) = 0;

pow( find( pow< powerMin ) ) = 0;
pow( find( powC> powerMaxClutter ) ) = 0;

sig( find( pow< powerMin ) ) = 0;
sig( find( powC> powerMaxClutter ) ) = 0;

% remove outliers
vel = medfilt2(vel);
sig = medfilt2(sig);
pow = medfilt2(pow);

% upsample
vel = interp2(vel,1);
sig = interp2(sig,1);
pow = interp2(pow,1);