
%In: path to a directory containing US files that are intended to be enhanced and saved as jpgs
function createJPGsFromUSPath(USFilesPath)    
    if ~isdir(USFilesPath)
        errorMessage = sprintf('Error: The following folder does not exist:\n%s', USFilesPath);
    end

    % Store jpg data in a subdirectory
    outputDir = strcat(USFilesPath, '\jpgs');
    if ~isdir(outputDir)
        mkdir(outputDir);
    end
    
    % Get a list of all files in the folder with the desired file name pattern.
    filePattern = fullfile(USFilesPath, '*.b8');
    theFiles = dir(filePattern);
    for k = 1 : length(theFiles)
        baseFileName = theFiles(k).name;
		baseFileName_NoExtension = baseFileName(1:end-3) %[name]
		
		lowerOutputDir = strcat(outputDir, '\', baseFileName_NoExtension);
		if ~isdir(lowerOutputDir)
			mkdir(lowerOutputDir);
		end
		
        fullFileName = fullfile(USFilesPath, baseFileName);

        fprintf(1, 'Now reading %s\n', fullFileName);
		
		displaySomeImages = true;
		readB8AndWriteJPGs(fullFileName, baseFileName_NoExtension, outputDir, displaySomeImages);
    end
end