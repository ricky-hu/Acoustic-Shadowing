% The following script reads GPS volume data and visualizes them. The user 
% needs to set both the path and the filename in the begining of the script.
%
% Copyright Ultrasonix Medical corporation - Analogic Ultrasound Group
% Author: Reza Zahiri Azar - Sept 2013

close all
clear
clc 
% add the path for the RP reader
addpath('..\common');

%%%%%%%%%%%%%  Reading Original Data with GPS %%%%%%%%%%%%%
path = 'data\';
fileName = 'FetusPhantom.gtv';
data = GPS3Dread([path, fileName]);

% displaying individual frames
figure;
set(gcf,'position',[19    96   560   795])
colormap(bone)
[X,Y,Z] = sphere;
for i=1:size(data.frames,1)
    % display GPS readings
    subplot(2,1,1)
    x = data.GPS.x(i); y = data.GPS.y(i); z = data.GPS.z(i);    % GPS readings
    % scale the sphere and displya at GPS readings
    surf(x+2*X,y+2*Y,z+2*Z);    
    camlight; lighting gouraud; shading interp; axis image;
    axis([min(data.GPS.x), max(data.GPS.x), min(data.GPS.y), ...
        max(data.GPS.y), min(data.GPS.z), max(data.GPS.z)]);
    title('GPS Sensor Readings');
    
    % display the images
    subplot(2,1,2)
    imagesc( squeeze(data.frames(i,:,:))', [0 255]);
    axis image; axis off;
    title('Acquired Images');
    drawnow;
end

%%%%%%%%%%%%%%%%% reading reconstructed volume %%%%%%%%%%%%%%%%%%%%%
fileName = 'FetusPhantom.grv';
vol = GPS3Dread([path, fileName]);

% displaying individual frames
figure;
colormap(copper)
for i=1:size(vol,3)/2
    imagesc(vol(:,:,i),[0 255]); axis off;
    title('Reconstructed Volume');
    drawnow;
end

%%%%%%%%%%%%%%%%%%%%%%% 3D visualization %%%%%%%%%%%%%%%%%%%%%%
v = vol(:,10:end-10,:);
v = shiftdim(v,1);
v = v(end:-1:1,end:-1:1,end:-1:1);
clear vol;

% displaying the volume
figure;
set(gca, 'position', [0   0   1   1]);
vol3d('CData',v,'texture','3D');
set(gca,'color','k'); set(gcf,'color','k');
axis image; axis vis3d; colormap(copper);
alphamap('decrease'); 
view(20,20);
% rotate the volume
step = 5;  % rotation step
for i=0:step:360
    camorbit(-step, 0);
    drawnow;
end


