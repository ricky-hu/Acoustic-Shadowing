% computeNakagamiMaps.m
% script to take all rf data in a directory and compute a map of nakagami
% dist
function computeNakagamiMaps(dirName)

patchSizeY = 30;
patchSizeX = 5;
numFrames = 1;

% getting list of .rf files
files = dir(fullfile(dirName, '*.rf'));
[numFiles dummy] = size(files);
for n = 1:numFiles
    fileName = files(n).name;
    [filepath,name,ext] = fileparts(fileName);
    
    if exist([name '_nakParams.mat'], 'file')
        %do nothing
        break;
    else
        [rf, headerRF] = RPread(fileName, numFrames);
        [rows cols] = size(rf);

        % averaging RF columns
        for i = 1:cols
            % handling cases where patch extends beyond boundaries
            if (i < floor(patchSizeX / 2) + 1 )
                rfAvg(:,i) = mean(rf(:,(1:(i+floor(patchSizeX/2)))),2);
            elseif (i > (cols - floor(patchSizeX / 2))) 
                rfAvg(:,i) = mean(rf(:,((i-floor(patchSizeX/2)):cols)),2);
            else
                rfAvg(:,i) = mean(rf(:, (i-floor(patchSizeX/2)):(i+floor(patchSizeX/2))),2);
            end
        end

        absHil = abs(hilbert(rfAvg));

        % creating patches first so this doesn't have to be repeated
        patchStartX = zeros(rows, cols);
        patchEndX = zeros(rows, cols);
        patchStartY = zeros(rows,cols);
        patchEndY = zeros(rows,cols);

        for i = 1:rows
            for j = 1:cols
                patchStartX(i,j) = j - floor(patchSizeX/2);
                patchEndX(i,j) = j + floor(patchSizeX/2);
                patchStartY(i,j) = i - floor(patchSizeY/2);
                patchEndY (i,j)= i + floor(patchSizeY/2);      

                if (i < floor(patchSizeY/2) + 1)
                    patchStartY(i,j) = 1;
                elseif (i > (rows - ceil(patchSizeY/2)) - 1)
                    patchEndY(i,j) = rows;
                end

                if (j < floor(patchSizeX/2) + 1)
                    patchStartX(i,j) = 1;
                elseif(j > (cols - ceil(patchSizeX/2) -1))
                    patchEndX(i,j) = cols;
                end
            end
        end

        % computing Nakagami parameters for each patch
        mu = zeros(rows,cols);
        omega = zeros(rows,cols);
        for i = 1:rows
            for j = 1:cols
                % patchX fixed as column 156 for now
                patch = absHil(patchStartY(i,j):patchEndY(i,j), patchStartX(i,j):patchEndX(i,j));
                nakaFitRow = fitdist(reshape(patch,[],1), 'Nakagami');
                mu(i,j) = nakaFitRow.mu;
                omega(i,j) = nakaFitRow.omega;
            end
        end

        % saving distribution data
        save([name '_nakParams'], 'mu', 'omega');
    end
end
    
    
    
