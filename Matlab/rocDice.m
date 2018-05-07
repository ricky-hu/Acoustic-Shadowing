% rocDice.m
% script that sweeps a bunch of omega values to get sensitivity and sspecifity scores
% run this in the directory of data
% should rewrite this later to a function
% all .rf files must have an associated _manual.png and _nakParams.mat file
files = dir(fullfile(pwd, '*.rf'));
[numFiles dummy] = size(files);

% sweeping omega = 0-20
roc = [];
for i = 1:numFiles
    fileName = files(i).name;
    [filepath,name,ext] = fileparts(fileName);
    display(name);
    load([name '_nakParams.mat'], 'file');
    
    numFrames = 1;
    rf = [];
    [rf, headerRF] = RPread([fileName '.rf'], numFrames);
    [rows cols] = size(rf);

    %Downsampling to 128 scanlines since sometimes the machines upsample
    %This also saves computation time later on
    rf = imresize(rf, [round(rows*128/cols) 128]);
    [rows cols] = size(rf);
    rfAvg = zeros(rows,cols);
    % averaging over scanlines
    for i = 1:cols
        % handling cases where patch extends beyond boundaries
        if (i < floor(patchSizeX / 2) + 1 )
            rfAvg(:,i) = mean(rf(:,(1:(i+floor(patchSizeX/2)))),2);
        elseif (i > (cols - floor(patchSizeX / 2))) 
            rfAvg(:,i) = mean(rf(:,((i-ceil(patchSizeX/2)):cols)),2);
        else
            rfAvg(:,i) = mean(rf(:, (i-floor(patchSizeX/2)):(i+floor(patchSizeX/2))),2);
        end
    end

    % performing absolute value of hilbert transform to obtain wavepacket of RF
    absHil = abs(hilbert(rfAvg));
    
    [detRows detCols] = size(absHil);
    omega = abs(imresize(omega, [round(rows*128/cols) 128]));
    
    manualName = [name '_manual.png'];
    manual = imread(manualName);
    
    % sweeping through omega threshold values
    for thresh = 1:25
        
        shadows = ones(detRows, detCols);
        pad = 30;
        for colIdx = 1:detCols

            %computing otsu thresholding levels for this scanline


            for rowIdx = pad:(detRows - pad)   
                if( log(omega(rowIdx, colIdx)) > thresh)
                    shadows(1:rowIdx, colIdx) = 1;
                end
            end
        end
        
        %getting sensitivity and specificity values
        %there is probably some clever binary logic way to do this
        tp = 0;
        tn = 0;
        fp = 0;
        fn = 0;

        [x y] = size(shadows);
        for row = x
            for col = y
                if ((shadows(x,y) == 0) && (manual(x,y) == 0))
                    tp = tp + 1;
                elseif((shadows(x,y) == 0) && (manual(x,y) == 1))
                    fp = fp + 1;
                elseif((shadows(x,y) == 1) && (manual(x,y) == 1))
                    tn = tn + 1;
                elseif((shadows(x,y) == 1) && (manual(x,y) == 0))
                    fn = fn + 1;
                end
            end
        end
        
        %computing sensitivity and 1 - specificity
        
        sens = tp/(tp + fn);
        spec = fn/(tn + fp);
        
        roc(thresh,1,i) = sens;
        roc(thresh,2,i) = (1 - spec);
    end
end
        
        
        
        
        
    

