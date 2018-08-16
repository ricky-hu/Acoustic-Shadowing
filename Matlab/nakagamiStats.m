%nakagamiStats.m computes mean adn standard deviation of Nakagami
%parameters of an image

function nakagamiStats(imName)

load([imName '_nakParams.mat']);
manual = imread([imName '_manual.png']);
% making shadows 0's and non-shadows 1's
manual = ~manual;

[numRows numCols] = size(omega);

muS = zeros(1, numRows*numCols);
muNS = zeros(1, numRows*numCols);
omegaS = zeros(1, numRows*numCols);
omegaNS = zeros(1, numRows*numCols);

idxS = 1;
idxNS = 1;
for col = 1:numCols
    for row = 1:numRows
        if manual(row,col) == 1
            % non-shadow
            omegaNS(1,idxNS) = omega(row,col);
            muNS(1,idxNS) = mu(row,col);
            idxNS = idxNS + 1;
        else
            omegaS(1,idxS) = omega(row,col);
            muS(1,idxS) = mu(row,col);
            idxS = idxS + 1;
        end
    end
end

endNS = find(omegaNS, 1, 'last');
endS = find(omegaS, 1, 'last');

% truncating tailing zeros and changing to log scale
omegaNS = log(omegaNS(1,1:endNS));
muNS = muNS(1,1:endNS);

omegaS = log(omegaS(1,1:endS));
muS = muS(1,1:endS);

% displaying stats

meanOmegaNS = mean(omegaNS)
meanOmegaS = mean(omegaS)
meanMuNS = mean(muNS)
meanMuS = mean(muS)

stdOmegaNS = std(omegaNS)
stdOmegaS = std(omegaS)
stdMuNS = std(muNS)
stdMuS = std(muS)
