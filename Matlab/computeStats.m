function patchStats = computeStats(patch)

patch = double(patch);

% computing mean and variance of the patch

avgPatch = mean2(patch);

varPatch = var(patch(:));
stdPatch = std2(patch);

if stdPatch == 0
    skewnessPatch = 0;
    kurtosisPatch = 0;
else
    skewnessPatch = avgPatch^3/stdPatch^3;
    kurtosisPatch = avgPatch^4/stdPatch^4;
end

patchStats = [avgPatch, stdPatch, varPatch, skewnessPatch, kurtosisPatch];
        


