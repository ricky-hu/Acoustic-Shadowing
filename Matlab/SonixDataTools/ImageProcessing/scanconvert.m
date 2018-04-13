function Iout = scanconvert(Iin, Apitch, Lpitch, Radius, PixelsPerMM)

if (Radius == 0) % A linear array probe
    AxialExtent   = Apitch * size(Iin, 1);
    LateralExtent = Lpitch * size(Iin, 2);
    AxialSize     = AxialExtent*1000*PixelsPerMM;
    LateralSize   = LateralExtent*1000*PixelsPerMM;
    Iout          = imageResize(Iin,LateralSize,AxialSize,2); % cubic interpolation 
else % A curved array probe
    t = ((1:size(Iin, 2))-size(Iin, 2)/2)*Lpitch/Radius;
    r = Radius + (1:size(Iin, 1))*Apitch;
    [t, r] = meshgrid(t, r);
    x = r.*cos(t);
    y = r.*sin(t);

    xreg = (min(x(:)):1e-3/PixelsPerMM:max(x(:)));
    yreg = (min(y(:)):1e-3/PixelsPerMM:max(y(:)));
    [yreg, xreg] = meshgrid(yreg, xreg);
    Iout = zeros(size(xreg));
    for xCntr = 1:size(xreg, 2)
        for yCntr = 1:size(yreg, 1)
            [theta, rho] = cart2pol(xreg(yCntr, xCntr), yreg(yCntr, xCntr));
            indt = floor(theta/(Lpitch/Radius)+size(Iin, 2)/2)+1;
            indr = floor((rho-Radius)/Apitch)+1;
            if and(indt>0, and(indt<size(t, 2) , and(indr>0, indr<size(r, 1))))
                Iout(yCntr, xCntr) = Iin(indr, indt);
            end
        end
    end
end
    