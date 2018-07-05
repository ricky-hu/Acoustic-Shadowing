% massOutlineShadowsPNG.m
% author:   Ricky Hu
% input:    dirName:    the directory where .png bmode images are located
% output:   saved .png files of the manual shadows

function massOutlineShadowsPNG(dirName)
files = dir(fullfile(dirName, '*_cropped.png'));
[numFiles dummy] = size(files);


for n = 1:numFiles
    fileName = files(n).name;
    [filepath,name,ext] = fileparts(fileName);
     if exist([name '_manual.png'], 'file')
        %do nothing
     else
         im = imread(files(n).name);
         fprintf('%s \n', name)
         boundaryThickness = 10;
         
         
         % prompting user to manually outline shadoww
         [manualShadowMatrix, boundaryShadowMatrix, deepShadowMatrix] = outlineShadow(im, fileName, boundaryThickness);
         
         % writing image, note that ROIpoly makes bounded region zero
         % (white), whereas we wnat bounded region to be black
         imwrite(~manualShadowMatrix, [name '_manual.png']);
     end
end
        
