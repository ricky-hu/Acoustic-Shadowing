%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function generates normalized frequencies which match the result of
% fftshift(fft(X)) where X is a 1, 2 or 3 dimensional matrix
%
% Usage: f = fftfreqs(N)
% Input:  N is the size(X) where X is the data for which the fft was taken
% Output: f is the normalized frequencies. f*Fs where Fs is the sampling
% frequency gives the actual frequencies in the 1D case...
%
% Copyright: Ultrasonix Medical Corporation Nov 2012
% Author: Ali Baghani, Research Scientist, ali.baghani@ultrasonix.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fftfreqs(N)

Cntr1 = 0;
f = {};
for nCntr = N
    Cntr1 = Cntr1 + 1;
    if (mod(nCntr, 2) == 1)
        f{Cntr1} = (-(nCntr-1)/2:(nCntr-1)/2)/nCntr;
    else
        f{Cntr1} = (-nCntr/2+1:nCntr/2)/nCntr;
    end
end

switch size(f, 1)
    case 1
        f = f{1};
    case 2
        f = meshgrid(f{1}, f{2});
    case 3
        f = meshgrid(f{1}, f{2}, f{3});        
end
