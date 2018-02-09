function patchStats = computeStats(patch)

[patchRows, patchCols] = size(patch);

% computing mean and variance of the patch

avgPatch = mean2(patch);
numPixels = patchRows*patchCols;

% computing variance, pretty sure there's a one or two liner to do this...
% note that bessel's correction is not used because all the samples of the
% dataset (the patch) are used in the computation so no sample variance is
% needed

varPatch = 0;
for rowIdx = 1:patchRows
    for colIdx = 1:patchCols
        varPatch = varPatch + (patch(rowIdx,colIdx) - avgPatch)^2 / numPixels;
    end
end

stdPatch = sqrt(varPatch);
skewnessPatch = avgPatch^3/stdPatch^3;
kurtosisPatch = avgPatch^4/stdPatch^4;

patchStats = [avgPatch, stdPatch, varPatch, skewnessPatch, kurtosisPatch];
        


