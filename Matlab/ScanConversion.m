classdef ScanConversion < handle
    % ScanConversion Implementation of scan conversion and reversion for
    % motorized curvilinear transducers.
    %
    % ScanConversion Methods:
    %   ScanConversion(varargin) - constructor for the class
    %   dataOut = ScanConvert(dataIn) - interpolate dataIn from transducer
    %       coordinates to dataOut in cartesian coordinates
    %   dataOut = ScanRevert(dataIn) - interpolate dataIn from cartesian
    %       coordinates to dataOut in transducer coordinates
    %   [px,py,pz] = ScanRevertPts(varargin) - compute the cartesian 
    %       coordinates of points based on the grid of points in transducer
    %       coordinates
    %   setClampMode(val) - specify whether to set outside values to 0 by
    %       setting the input to false or to use cubic interpolation to
    %       extrapolate values by setting the input to true.
    %
    %   Jeff Abeysekera, June 2016
    
    properties (Access = private)
        % curvilinear geometry
        dR = 0.0;
        dTheta = 0.0;
        dPhi = 0.0;
        nR = 0;
        nTheta = 0;
        nPhi = 0;
        
        % cartesian geometry
        dX = 0.0;
        dY = 0.0;
        dZ = 0.0;
        nX = 0;
        nY = 0;
        nZ = 0;
        
        % probe geometry
        Rt = 0.0; % probe radius: > 0 for curvilinear, <= 0 for linear
        Rm = 0.0; % motor radius: > 0 for curved motion, <= 0 for linear
        
        % internal variables
        nXD = 0;
        nYD = 0;
        minX = 0;
        minY = 0;
        minZ = 0;
        maxX = 0;
        maxY = 0;
        maxZ = 0;
        minR = 0;
        probeType = 0; % can be of one of the following combinations:
                    % 0: curvilinear transducer + curved motor motion
                    % 1: linear transducer + curved motor motion
                    % 2: curvilinear transducer + linear motor motion
                    % 3: linear transducer + linear motor motion	
        clampMode = false; % when set to false (default) the query points
                    % falling outside of the provided data will be set to 0
                    % when set to true, the values will be extrapolated
                    % using cubic interpolation
        preAllocatedSC = false; % flag for tracking whether or not data has
                    % been preallocated or not
        preAllocatedSR = false;
        xSC = [];
        ySC = [];
        zSC = [];
        trSC = [];
        ttSC = [];
        tpSC = [];
        prSC = [];
        ptSC = [];
        ppSC = [];
        xSR = [];
        ySR = [];
        zSR = [];
        tSR = [];
        rSR = [];
        pSR = [];
    end
    
    methods (Access = public)
        function obj = ScanConversion(varargin)
            % obj = ScanConversion(varargin)
            %   Constructor of ScanConversion object
            %   There are three valid calls to properly initialize the
            %   object:
            %   ScanConversion(Rt, Rm, dR, dTheta, dPhi, nR, nTheta, ...
            %           nPhi, nY, nX, nZ, dY, dX, dZ)
            %   ScanConversion(Rt, Rm, dR, dTheta, dPhi, nR, nTheta, ...
            %           nPhi, dY, dX, dZ)
            %   ScanConversion(Rt, Rm, dR, dTheta, dPhi, nR, nTheta, ...
            %           nPhi, nY, nX, nZ, pixelSizeY, pixelSizeX)
            
            
            if nargin > 0
                obj.Rt      = varargin{1};
                obj.Rm      = varargin{2};
                obj.dR      = varargin{3};
                obj.dTheta  = varargin{4};
                obj.dPhi    = varargin{5};
                obj.nR      = varargin{6};
                obj.nTheta  = varargin{7};
                obj.nPhi    = varargin{8};
                
                Rt_abs = abs(obj.Rt);
                % CTCM
                if ( (Rt_abs > 0.0) && (obj.Rm > 0.0) ) 
                    obj.probeType = 0;

                    D = abs( obj.Rt-obj.Rm );
                    obj.minY = ( obj.Rt*cos( obj.nTheta/2.0 * obj.dTheta ) - D ) * cos( obj.nPhi/2.0 * obj.dPhi ) + D;
                    obj.maxY = obj.Rt + obj.dR*obj.nR;
                    obj.minR = obj.Rt;

                    obj.minX = -sin( obj.nTheta/2.0 * obj.dTheta ) * obj.maxY;
                    obj.maxX =  sin( obj.nTheta/2.0 * obj.dTheta ) * obj.maxY;

                    obj.minZ = -sin( obj.nPhi/2.0 * obj.dPhi ) * obj.maxY;
                    obj.maxZ =	sin( obj.nPhi/2.0 * obj.dPhi ) * obj.maxY;
                % LTCM
                elseif ( (Rt_abs <= 0.0) && (obj.Rm > 0.0) )
                    obj.probeType = 1;

                    obj.minY = obj.Rm * cos( obj.nPhi/2.0 * obj.dPhi );
                    obj.maxY = obj.Rm + obj.dR*obj.nR;
                    obj.minR = obj.Rm;%obj.minY;

                    obj.minX = -obj.nTheta/2.0 * obj.dTheta;   
                    obj.maxX =  obj.nTheta/2.0 * obj.dTheta;	

                    obj.minZ = -sin( obj.nPhi/2.0 * obj.dPhi ) * obj.maxY;
                    obj.maxZ =  sin( obj.nPhi/2.0 * obj.dPhi ) * obj.maxY;
                % CTLM
                elseif ( (Rt_abs > 0.0) && (obj.Rm <= 0.0) )
                    obj.probeType = 2;
                    if obj.Rt > 0
                        obj.minY = obj.Rt * cos( obj.nTheta/2.0 * obj.dTheta );
                        obj.maxY = obj.Rt + obj.dR*obj.nR;
                        obj.minR = obj.Rt;
                        
                        obj.minX = -sin( obj.nTheta/2.0 * obj.dTheta ) * obj.maxY;
                        obj.maxX =  sin( obj.nTheta/2.0 * obj.dTheta ) * obj.maxY;
                    else
                        % ensure dTheta is positive
                        obj.dTheta = abs(obj.dTheta);
                        
                        obj.minY = obj.Rt;
                        obj.maxY = (obj.Rt + obj.dR*obj.nR)*cos( obj.nTheta/2.0 * obj.dTheta );
                        obj.minR = obj.Rt;
                        
                        obj.minX = -sin( obj.nTheta/2.0 * obj.dTheta ) * Rt_abs;
                        obj.maxX = sin( obj.nTheta/2.0 * obj.dTheta ) * Rt_abs;
                    end

                    obj.minZ = -obj.nPhi/2.0 * obj.dPhi;   
                    obj.maxZ =  obj.nPhi/2.0 * obj.dPhi;	
                % LTLM
                elseif ( (Rt_abs <= 0.0) && (obj.Rm <= 0.0) )
                    obj.probeType = 3;

                    obj.minY = 0.0;
                    obj.maxY = obj.dR*obj.nR;
                    obj.minR = 0.0;

                    obj.minX = -obj.nTheta/2.0 * obj.dTheta;   
                    obj.maxX =  obj.nTheta/2.0 * obj.dTheta;

                    obj.minZ = -obj.nPhi/2.0 * obj.dPhi;   
                    obj.maxZ =  obj.nPhi/2.0 * obj.dPhi;
                end
                
                if nargin == 14
                    obj.nY = varargin{9};
                    obj.nX = varargin{10};
                    obj.nZ = varargin{11};
                    obj.dY = varargin{12};
                    obj.dX = varargin{13};
                    obj.dZ = varargin{14};
                    obj.nXD = obj.nX;
                    obj.nYD = obj.nY;
                elseif nargin == 11 % don't know nX, nY, nZ
                    obj.dY = varargin{9};
                    obj.dX = varargin{10};
                    obj.dZ = varargin{11};
                    obj.nX = floor( ((obj.maxX-obj.minX)/obj.dX) ) + 1;
                    obj.nY = floor( ((obj.maxY-obj.minY)/obj.dY) ) + 1;
                    obj.nZ = floor( ((obj.maxZ-obj.minZ)/obj.dZ) ) + 1;
                    obj.nXD = obj.nX;
                    obj.nYD = obj.nY;
                elseif nargin == 13 % used for displays with aspect ratio
                    obj.nY = varargin{9};
                    obj.nX = varargin{10};
                    obj.nZ = varargin{11};
                    pixelSizeY = varargin{12};
                    pixelSizeX = varargin{13};
                    
                    obj.nXD = obj.nX;
                    obj.nYD = obj.nY;
                    
                    if obj.nX ~= 1
                        obj.dX = (obj.maxX-obj.minX)/(obj.nX-1);
                    else
                        obj.dX = 1.0;
                    end
                    if obj.nY ~= 1
                        obj.dY = (obj.maxY-obj.minY)/(obj.nY-1);
                    else
                        obj.dY = 1.0;
                    end
                    if obj.nZ ~= 1
                        obj.dZ = (obj.maxZ-obj.minZ)/(obj.nZ-1);
                    else
                        obj.dZ = 1.0;
                    end
                    
                    if( obj.dY/obj.dX < pixelSizeY/pixelSizeX )
                        obj.dY = (pixelSizeY/pixelSizeX) * obj.dX;
                        obj.nYD = floor( (obj.maxY-obj.minY)/obj.dY ) + 1;
                        if obj.nYD > obj.nY
                            obj.nYD = obj.nY;
                        end
                    else
                        obj.dX = (pixelSizeX/pixelSizeY) * obj.dY;
                        obj.nXD = floor( (obj.maxX-obj.minX)/obj.dX ) + 1;
                        if obj.nXD > obj.nX
                            obj.nXD = obj.nX;
                        end
                    end
                else
                    error('Wrong number of input arguments');
                end
            end
        end
        
        function [nX,nY,nZ,dX,dY,dZ] = getCartGeo(obj)
            % [nX,nY,nZ,dX,dY,dZ] = getCartGeo()
            % Returns the number of grid points in the x, y, and z
            % directions in the cartesian coordinate system and the spacing
            % in each direction
            
            nX = obj.nX;
            nY = obj.nY;
            nZ = obj.nZ;
            dX = obj.dX;
            dY = obj.dY;
            dZ = obj.dZ;
        end
        
        function [minX, minY, minZ] = getCartBoundary(obj)
            % [minX, minY, minZ] = getCartBoundary()
            % Returns the minimum value in cartesian coordinates of the
            % scan converted grid edges
            
            minX = obj.minX;
            minY = obj.minY;
            minZ = obj.minZ;
        end
        
        function setClampMode(obj,val)
            % setClampMode(val)
            % Sets the value of the clamp variable. Set to true to use
            % cubic interoplation to extrapolate values. Set to false to
            % set outside values to 0 (default).
            
            obj.clampMode = val;
        end
        
        function dataOutCentred = ScanConvert(obj,dataIn)
            % dataOut = ScanConvert(dataIn)
            % Input an array of pre scan data in transducer coordinates and
            % output an array of post scan converted data in cartesian
            % coordinates.

            if( ~obj.preAllocatedSC )
                obj.preAllocateSC();
            end
            
            if( obj.clampMode == true )
                ExtrapMethod = 'cubic';
            else
                ExtrapMethod = 'none';
            end
            
            if( obj.nZ == 1 )
%                 out = interp2(tt,tr,dataIn,pt,pr,'linear',0);
                F = griddedInterpolant(obj.ttSC,obj.trSC,permute(dataIn,[2 1]),'linear',ExtrapMethod);
                out = F(obj.ptSC,obj.prSC);
            else
%                 out = interp3(tt,tr,tp,dataIn,pt,pr,pp,'linear',0);
                F = griddedInterpolant(obj.ttSC,obj.trSC,obj.tpSC,permute(dataIn,[2 1 3]),'linear',ExtrapMethod);
                out = F(obj.ptSC,obj.prSC,obj.ppSC);
            end
            out(isnan(out)) = 0;
            dataOut = permute(out,[2 1 3]);
            
            % center the output
            dataOutCentred = zeros(obj.nY,obj.nX,obj.nZ);
            xOffset = 1;
            yOffset = 1;
            if obj.nX ~= obj.nXD
                xOffset = ceil((obj.nX - obj.nXD)/2);
            end
            if obj.nY ~= obj.nYD
                yOffset = ceil((obj.nY - obj.nYD)/2);
            end
           
            dataOutCentred(yOffset:yOffset+obj.nYD-1,xOffset:xOffset+obj.nXD-1,:) = dataOut;
            
        end
        
        function dataOut = ScanRevert(obj,dataIn)
            % dataOut = ScanRevert(dataIn)
            % Input an array of scan converted data in cartesian 
            % coordinates and output an array of pre scan converted data 
            % in transducer coordinates.
            
%             xx = permute(x,[2 1 3]);
%             yy = permute(y,[2 1 3]);
%             zz = permute(z,[2 1 3]);
            if( ~obj.preAllocatedSR )
                obj.preAllocateSR()
            end
            
            [px,py,pz] = ScanRevertPts(obj);
            
            if( obj.clampMode == true )
                ExtrapMethod = 'cubic';
            else
                ExtrapMethod = 'none';
            end
            
            if( obj.nZ == 1 )
%                 out = interp2(xx,yy,dataIn,px,py,'linear',0);
                F = griddedInterpolant(obj.xSR,obj.ySR,permute(dataIn,[2 1]),'linear',ExtrapMethod);
                out = F(px,py);
            else
%                 out = interp3(xx,yy,zz,dataIn,px,py,pz,'linear',0);
                F = griddedInterpolant(obj.xSR,obj.ySR,obj.zSR,permute(dataIn,[2 1 3]),'linear',ExtrapMethod);
                out = F(px,py,pz);
            end
            out(isnan(out)) = 0;
            dataOut = permute(out,[2 1 3]);
        end
        
        function [px,py,pz] = ScanRevertPts(obj,varargin)
            % [px,py,pz] = ScanRevertPts(varargin)
            % Computes the cartesian coordinates of points based on the
            % grid of points in transducer coordinates.
            % Optional input of three arrays of size [nTheta,nR,nPhi]
            % specifying shifts in each of the three transducer coordinates
            % which can be used for calculating displacements after using
            % speckle tracking to estimate shifts in transducer coordintes.
            % The first arrays should specify the shifts in Theta, the
            % second the shifts in R, and the third shifts in Phi.
            % Optional input of one array of size Nx3 specifying N 
            % locations in transducer coordinates in the theta, radial, and
            % phi directions. Useful for determining cartesian coordinates
            % of pre-scan converted segmentation points.
            
            if( ~obj.preAllocatedSR )
                obj.preAllocateSR()
            end
            
            if( nargin > 1 )
                if( nargin == 4 )
                    dt = varargin{1};
                    dr = varargin{2};
                    dp = varargin{3};
                    
                    t = obj.tSR + dt;
                    r = obj.rSR + dr;
                    p = obj.pSR + dp;
                elseif( nargin == 2)
                    A = varargin{1};
                    t = A(:,1);
                    r = A(:,2);
                    p = A(:,3);
                else
                    error('Invalid number of input arguments. Please either leave empty or input 1 or 3 arrays.');
                end
            else
                t = obj.tSR;
                r = obj.rSR;
                p = obj.pSR;
            end
            
%             px = zeros(obj.nTheta, obj.nR, obj.nPhi);
%             py = zeros(obj.nTheta, obj.nR, obj.nPhi);
%             pz = zeros(obj.nTheta, obj.nR, obj.nPhi);
            
            if obj.probeType == 0 % CTCM
                D = abs(obj.Rt-obj.Rm);
%                 for a=1:obj.nTheta
%                     for b=1:obj.nR
%                         for c=1:obj.nPhi
%                             rp = r(a,b,c)*cos(t(a,b,c));
%                             px(a,b,c) = rp*tan(t(a,b,c));
%                             py(a,b,c) = D + (rp - D)*cos(p(a,b,c));
%                             pz(a,b,c) = (py(a,b,c) - D)*tan(p(a,b,c));
%                         end
%                     end
%                 end
                rp = r.*cos(t);
                px = rp.*tan(t);
                py = D + (rp - D).*cos(p);
                pz = (py - D).*tan(p);
            elseif obj.probeType == 1 % LTCM
%                 for a=1:obj.nTheta
%                     for b=1:obj.nR
%                         for c=1:obj.nPhi
%                             pz(a,b,c) = r(a,b,c)*sin(p(a,b,c));
%                             px(a,b,c) = t(a,b,c);
%                             py(a,b,c) = r(a,b,c)*cos(p(a,b,c))-obj.minY;
%                         end
%                     end
%                 end
                pz = r.*sin(p);
                px = t;
                py = r.*cos(p) - obj.minY;
            elseif obj.probeType == 2 % CTLM
%                 for a=1:obj.nTheta
%                     for b=1:obj.nR
%                         for c=1:obj.nPhi
%                             pz(a,b,c) = p(a,b,c);
%                             px(a,b,c) = r(a,b,c)*sin(t(a,b,c));
%                             py(a,b,c) = r(a,b,c)*cos(t(a,b,c));
%                         end
%                     end
%                 end
                pz = p;
                px = r.*sin(t);
                py = r.*cos(t);
            elseif obj.probeType == 3 % LTLM
%                 for a=1:obj.nTheta
%                     for b=1:obj.nR
%                         for c=1:obj.nPhi
%                             pz(a,b,c) = p(a,b,c);
%                             px(a,b,c) = t(a,b,c);
%                             py(a,b,c) = r(a,b,c);
%                         end
%                     end
%                 end
                pz = p;
                px = t;
                py = r;
            end
        end
    end
    
    methods (Access=private)
        function preAllocateSC(obj)
            %%%%%%%%%%%%%%%%%%
            % Scan Conversion
            %%%%%%%%%%%%%%%%%%
            [obj.xSC,obj.ySC,obj.zSC] = ndgrid(((-(obj.nX-1)/2):((obj.nX-1)/2))*obj.dX,...
                obj.minY:obj.dY:obj.maxY,...
                ((-(obj.nZ-1)/2):((obj.nZ-1)/2))*obj.dZ);
            
%             obj.ppSC = zeros(obj.nX,obj.nY,obj.nZ);
%             obj.ptSC = zeros(obj.nX,obj.nY,obj.nZ);
%             obj.prSC = zeros(obj.nX,obj.nY,obj.nZ);
            
            if obj.probeType == 0 % CTCM
                D = abs(obj.Rt-obj.Rm);
                [obj.trSC,obj.ttSC,obj.tpSC] = ndgrid((0:(obj.nR-1))*obj.dR + obj.Rt,...
                ((0:(obj.nTheta-1)) + 0.5 - obj.nTheta/2)*obj.dTheta,...
                ((0:(obj.nPhi-1)) + 0.5 - obj.nPhi/2)*obj.dPhi);
            else
                D = 0;
                [obj.trSC,obj.ttSC,obj.tpSC] = ndgrid((0:(obj.nR-1))*obj.dR + D,...
                ((0:(obj.nTheta-1)) + 0.5 - obj.nTheta/2)*obj.dTheta,...
                ((0:(obj.nPhi-1)) + 0.5 - obj.nPhi/2)*obj.dPhi);
            end
            
            

            if obj.probeType == 0 % CTCM  
%                 for a=1:obj.nX
%                    for b=1:obj.nY
%                        for c=1:obj.nZ
%                            % Find motor angle Phi for each point from axial distance and
%                            % elevation:
%                            pp(a,b,c) = atan(z(a,b,c)/(y(a,b,c)-D));
%                            % Find distance of the point to the motor, then add offSetDiff
%                            % (this is the radius of the point assuming it is centred along
%                            % the linear probe):
%                            rp = D + (y(a,b,c)-D)/cos(pp(a,b,c));
%                            % Find theta from lateral distance and rp:
%                            pt(a,b,c) = atan(x(a,b,c)/rp);
%                            % Find radius of the point from the probe origin:
%                            pr(a,b,c) = rp/cos(pt(a,b,c));	
%                        end
%                    end
%                 end
                obj.ppSC = atan(obj.zSC./(obj.ySC-D));
                rp = D + (obj.ySC-D)./cos(obj.ppSC);
                obj.ptSC = atan(obj.xSC./rp);
                obj.prSC = rp./cos(obj.ptSC);
            elseif obj.probeType == 1 % LTCM        
%                 for a=1:obj.nX
%                    for b=1:obj.nY
%                        for c=1:obj.nZ
%                            % Find motor angle Phi for each point from axial distance and
%                            % elevation:
%                            pp(a,b,c) = atan(z(a,b,c)/y(a,b,c));
%                            % Find theta from lateral distance:
%                            pt(a,b,c) = x(a,b,c);
%                            % Find radius of the point from the probe origin:
%                            pr(a,b,c) = sqrt(y(a,b,c)^2 + z(a,b,c)^2)-obj.Rm;%sqrt(y(a,b,c)^2 + z(a,b,c)^2)-obj.minY;	
%                        end
%                    end
%                 end
                obj.ppSC = atan(obj.zSC./obj.ySC);
                obj.ptSC = obj.xSC;
                obj.prSC = sqrt(obj.ySC.^2 + obj.zSC.^2) - obj.Rm;
            elseif obj.probeType == 2 % CTLM
%                 for a=1:obj.nX
%                    for b=1:obj.nY
%                        for c=1:obj.nZ
%                            % Find motor angle Phi for each point from elevation:
%                            pp(a,b,c) = z(a,b,c);
%                            % Find theta from lateral and axial distance:
%                            pt(a,b,c) = atan(x(a,b,c)/y(a,b,c));
%                            % Find radius of the point from the probe origin:
%                            pr(a,b,c) = sqrt(y(a,b,c)^2 + x(a,b,c)^2)-obj.Rt;	
%                        end
%                    end
%                 end
                obj.ppSC = obj.zSC;
                obj.ptSC = atan(obj.xSC./obj.ySC);
                if obj.Rt < 0
                    obj.prSC = abs(obj.Rt) - sqrt(obj.ySC.^2 + obj.xSC.^2);
                else
                    obj.prSC = sqrt(obj.ySC.^2 + obj.xSC.^2) - obj.Rt;
                end
            elseif obj.probeType == 3 % LTLM
%                 for a=1:obj.nX
%                    for b=1:obj.nY
%                        for c=1:obj.nZ
%                            % Find motor angle Phi for each point from elevation:
%                            pp(a,b,c) = z(a,b,c);
%                            % Find theta from lateral and axial distance:
%                            pt(a,b,c) = x(a,b,c);
%                            % Find radius of the point from the probe origin:
%                            pr(a,b,c) = y(a,b,c);	
%                        end
%                    end
%                 end
                obj.ppSC = obj.zSC;
                obj.ptSC = obj.xSC;
                obj.prSC = obj.ySC;
            end
            
            P = [2 1 3];
            obj.ttSC = permute(obj.ttSC,P);
            obj.trSC = permute(obj.trSC,P);
            obj.tpSC = permute(obj.tpSC,P);
            %figure; subplot(1,2,1); imagesc(obj.trSC,[-1 1]*100); subplot(1,2,2); imagesc(obj.prSC,[-1 1]*100);
            % Set the preAllocated flag
            obj.preAllocatedSC = true;
        end
        
        function preAllocateSR(obj)
            %%%%%%%%%%%%%%%%%%
            % Scan Reversion
            %%%%%%%%%%%%%%%%%%
            if( obj.probeType == 1 || obj.probeType == 3 )
                [obj.xSR,obj.ySR,obj.zSR] = ndgrid(((-(obj.nX-1)/2):((obj.nX-1)/2))*obj.dX,...
                    (0:(obj.nY-1))*obj.dY,...
                    ((-(obj.nZ-1)/2):((obj.nZ-1)/2))*obj.dZ);
            else
                [obj.xSR,obj.ySR,obj.zSR] = ndgrid(((-(obj.nX-1)/2):((obj.nX-1)/2))*obj.dX,...
                    obj.minY:obj.dY:obj.maxY,...
                    ((-(obj.nZ-1)/2):((obj.nZ-1)/2))*obj.dZ);
            end
            
            [obj.tSR,obj.rSR,obj.pSR] = ndgrid(((-(obj.nTheta-1)/2):((obj.nTheta-1)/2))*obj.dTheta,...
                obj.minR + (0:(obj.nR-1))*obj.dR,...
                ((-(obj.nPhi-1)/2):((obj.nPhi-1)/2))*obj.dPhi);
            
            % Set the preAllocated flag
            obj.preAllocatedSR = true;
        end
    end
end