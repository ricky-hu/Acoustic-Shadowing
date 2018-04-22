% outlineShadow.m
% author:   Ricky Hu
% input:    an nxn matrix corresponding to an image and the base filename
%           with no extension to save the manual outlined shadow
% output:   an nxnx3 matrix consisting of the following submatrices:
%           nxnx1: a matrix of 1 (no shadow) or 0 (shadow)
%           nxnx2: a matrix of 1 (not a shadow boundary) or 0 (within some)
%           pixels of a shadow boundary highlighted by user)
%           nxnx3: a matrix of 1 (not deep inside a shadow region) or 0
%           (deep within a shadow region)

function manualShdwMatrix = outlineShadow(image, fileName)

% Parameter defining the thickness of the boundary, which will be used
% later on to compute some local statistics on the boundary area

boundaryThickness = 10;



% This step prompts the user to highlight the region of interest if there
% isn't also a highlighted image

if exist('manual.png', 'file')
    manualShdw = imread('manual.png');
else
    % Obtaining manual outline of shadow region
    imshow(image);
    manualShdw = roipoly;
    imwrite(manualShdw, 'manual.png');
end

% Note that MATLAB fills the outlined polygon with white, which is the
% opposite of the shadowing algorithm (fills it with black), so the values
% are flipped to compare

manualShdw = ~manualShdw;

% Constructing the matrix representing the manual shadow regions and the
% shadow boundary and deep shadowing regions

manualShdwMatrix(:,:,1) = manualShdw;

boundaryMatrix = manualShdw;
deepShadowMatrix = manualShdw;

[rows, cols] = size(boundaryMatrix);

% Using the manual shadow matrix to create a matrix highlighting only the
% boundary regions (only the boundary regions will be black) and only the
% deep shadowing regions (only the regions deep within the shadow will be
% black)
for colIdx = 1:cols
    for rowIdx = 1:rows
        if boundaryMatrix(rowIdx, colIdx) == 0
            
            % Handling cases where the boundary thickness may exceed the
            % boundaries of the image
            
            if(rowIdx - boundaryThickness < 1)
                boundaryThickness = rowIdx - 1;
            elseif(rowIdx + boundaryThickness > rows)
                boundaryThickness = rows - rowIdx;
            end
            boundaryMatrix(:,colIdx) = 1;
            boundaryMatrix((rowIdx - boundaryThickness):(rowIdx + boundaryThickness), colIdx) = 0;
            deepShadowMatrix(:,colIdx) = 1;
            deepShadowMatrix((rowIdx + boundaryThickness + 1):end,colIdx) = 0;            
            break;
        end
    end
end

manualShdwMatrix(:,:,2) = boundaryMatrix;
manualShdwMatrix(:,:,3) = deepShadowMatrix;

% optional - showing figures corresponding to subsections
% figure()
% imshow(manualShdwMatrix(:,:,1));
% figure()
% imshow(manualShdwMatrix(:,:,2));
% figure()
% imshow(manualShdwMatrix(:,:,3));
