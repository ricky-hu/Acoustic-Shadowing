function newimg = imageResize(img,width,height, method)
% imageResize Resize an image using different interpolation techniques
%
% usage    newImg = imageResize(IMG,W,H,1) Given input image IMG,
%          returns a new image NEWIMG of size WxH reconstructed using 
%          linear interpolation.
% Reza Zahiri Azar, Ultrasonix Medical Corp. 2006 

if nargin ~= 4
error('usage: imageResize(image,w,h,method)');
end;

ht_scale  = size(img,1) / height;
wid_scale = size(img,2) / width;

if (method == 0)
    newimg = interp2(img,(1:width)*wid_scale,(1:height)'*ht_scale,'nearest');
elseif (method == 1)
    newimg = interp2(img,(1:width)*wid_scale,(1:height)'*ht_scale,'linear');
elseif (method == 2)
    newimg = interp2(img,(1:width)*wid_scale,(1:height)'*ht_scale,'cubic');
else 
    newimg = interp2(img,(1:width)*wid_scale,(1:height)'*ht_scale,'spline');
end;  