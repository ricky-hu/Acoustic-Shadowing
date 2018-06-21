% cropPNGsBecauseOfStupidBlackfill.m
% function to crop the PNGs depending if it is linear/curved or
% abdominal/arm to get rid of blackfill because the ultrasonix machines
% pads with black pixels that I don't know how to turn off.

function cropPNGs(imDir)

% looks at entire directory for PNGs sized 660 (w) x 616 (h)

