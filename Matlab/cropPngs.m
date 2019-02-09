% cropPNGsBecauseOfStupidBlackfill.m
% function to crop the PNGs depending if it is linear/curved or
% abdominal/arm to get rid of blackfill because the ultrasonix machines
% pads with black pixels that I don't know how to turn off.

% crops:
% linear: (76:539,151:511)
% curvilinear: (80:530,all)
function cropPNGs(imDir)

% looks at entire directory for PNGs sized 660 (w) x 616 (h)

files = dir(fullfile(imDir, '*.png'));
[x y] = size(files);

for i = 1:x
    
    im = imread(files(i).name);
   
    % cropping out blackfill depending on what image it is
    
    % linear
    if (contains(files(i).name, '_l_'))
        imCropped = im(76:539, 181:482);
    else
        % curvilinear
        imCropped = im(80:530,:);
    end
    
    imName = files(i).name;
    
    % making the image name, removing the '_1.png'

    imName = imName(1:end-6);
    imName = [imName '_cropped.png'];
    imwrite(imCropped, imName);
end

 
        