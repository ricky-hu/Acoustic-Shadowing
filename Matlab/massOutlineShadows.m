% massOutlineShadows.m
% helping script to take all unoutlined images and outline the shadows in a
% directory

function massOutlineShadows(dirName)
files = dir(fullfile(dirName, '*.rf'));
[numFiles dummy] = size(files);
numFrames = 1;

for n = 1:numFiles
    fileName = files(n).name;
    [filepath,name,ext] = fileparts(fileName);
     if exist([name '_manual.png'], 'file')
        %do nothing
     else
        if exist([name '_nakParams.mat'], 'file')
            [rf, headerRF] = RPread(fileName, numFrames);
            logAbsHil = log(abs(hilbert(rf)));   
            [rows cols] = size(rf);
            
            patchSizeX = 5;
            patchSizeY = 30;
            
            rfAvg = zeros(rows,cols);
            
            for i = 1:cols
                % handling cases where patch extends beyond boundaries
                if (i < floor(patchSizeX / 2) + 1 )
                    rfAvg(:,i) = mean(rf(:,(1:(i+floor(patchSizeX/2)))),2);
                elseif (i > (cols - floor(patchSizeX / 2))) 
                    rfAvg(:,i) = mean(rf(:,((i-ceil(patchSizeX/2)):cols)),2);
                else
                    rfAvg(:,i) = mean(rf(:, (i - floor(patchSizeX/2)):(i + floor(patchSizeX/2))),2);
                end
            end
            absHil = abs(hilbert(rf));

            load([name '_nakParams.mat']);
            % assuming Nakagami maps have been computed to save time (can be changed later to call
            % computeNakagamiMaps function

            % detecting shadow susing otsu's method to threshold nakagami parameters

            [detRows detCols] = size(absHil);

            % thresholding by the scale parameter w

            % padding ringdown

            pad = 30;

            shadows = zeros(detRows, detCols);

            for colIdx = 1:detCols

                %computing otsu thresholding levels for this scanline
                levelLineW = multithresh(log(omega(:,colIdx)));
                levelLineU = multithresh(log(mu(:,colIdx)));

                for rowIdx = pad:(detRows - pad)   
                    if( log(omega(rowIdx, colIdx)) > levelLineW)
                        shadows(1:rowIdx, colIdx) = 1;
                    end
                end
            end            
            
            figure(1)
            f(1) = subplot(1,3,1);
            imagesc(log(absHil));
            title('log(abs(hilbert(rf))) (almost b-mode)');
            colormap(gca,'gray');
            hcb = colorbar;

            f(2) = subplot(1,3,2);
            imagesc(shadows);
            title('Detected shadows');  
            colormap(gca,'gray');
            hcb = colorbar;  
            
            boundaryThickness = 10;
            [manualShadowMatrix, boundaryShadowMatrix, deepShadowMatrix] = outlineShadow(logAbsHil, fileName, boundaryThickness);
        end
     end
end
        
