% cropBModeL.m
% crops the blackfill of linear B-mode images

function im = cropBModeL(filename)

image = imread(filename);
x1 = 151;
x2 = 511;
y1 = 76;
y2 = 539;
im = image(x1:x2,y1:y2);