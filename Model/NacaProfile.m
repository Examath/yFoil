classdef NacaProfile
    % NacaProfile Represents a NACA profile
    %   A naca profile is an aerofoil described by three parameters.
    %   See https://en.wikipedia.org/wiki/NACA_airfoil

    methods (Static)
        function naca = GenerateFromDigits(inputDigits)
            %GENERATEFROMDIGITS Trys to generate a naca profile from the 4-digit
            %specifier
            %   This attempts to create a NacaProfile instance from
            %   the 4-digit specifier. success is true if t=it is succesful
            arguments
                % String containing the 4-digit specifier
                inputDigits {mustBeTextScalar}
            end

            % Check if 4 digits
            if (length(inputDigits) == 4)
                maximumChamber = str2double(inputDigits(1)) / 100;
                locationChamber = str2double(inputDigits(2)) / 10;
                thickness = str2double(inputDigits(3:4)) / 100;

                % Check if all valid
                if (~(isnan(maximumChamber) || isnan(locationChamber) || isnan(thickness)))
                    naca = NacaProfile(maximumChamber, locationChamber, thickness);
                    return
                end
            end

            naca = [];
        end
    end

    properties
        % Maximum chamber as a fraction of chord
        M
        % Position of the maximum chamber as a fraction of chord
        P
        % Thickness as a fraction of chord
        T
        % A 2 by m matrix that stores the points forming the upper surface 
        % of the profile
        UpperSurface
        % A 2 by m matrix that stores the points forming the chamber line
        % of the profile
        ChamberLine
        % A 2 by m matrix that stores the points forming the lower surface 
        % of the profile
        LowerSurface
    end

    methods
        function this = NacaProfile(maximumChamber, locationChamber, thickness)
            % NacaProfile Construct and generate an instance of the profile
            %   Note this does not generate the surface. 
            %   Call ComputeSurface() to do that.
            arguments
                % All parameters should be scalar numbers
                maximumChamber (1,1) {mustBeReal} = 0
                locationChamber (1,1) {mustBeReal} = 0
                thickness (1,1) {mustBeReal} = 0.3
            end

            % Set properties
            this.M = maximumChamber;
            this.P = locationChamber;
            this.T = thickness;

            % Compute surface
            % TBC
        end

        function obj = ComputeSurface(obj, xPositions)
            %COMPUTESURFACE Compute the points that make up this surface

            % Preallocate matrix for efficiency
            obj.UpperSurface = zeros(2,length(xPositions));
            obj.ChamberLine = zeros(2,length(xPositions));
            obj.LowerSurface = zeros(2,length(xPositions));

            % To generate surface, loop through the provided x-positions
            % and generate respective point on both surfaces:
            for index = 1:length(xPositions)
                % Get point pair (it is more efficient to simultaneously
                % compute corresponding upper, chamber and lower points
                pointPair = ComputePointPair(obj, xPositions(index));

                % Store points
                obj.UpperSurface(:, index) = pointPair(:,1);
                obj.ChamberLine(:, index) = pointPair(:,2);
                obj.LowerSurface(:, index) = pointPair(:,3);
            end

            % Left most point must be the origin and first point
            % of both surfaces
            
            % Find left-most point on upper surface
            leftMostPosition = obj.UpperSurface(1,1);
            for index = 2:length(xPositions)
                % If this point is left-er than previous
                if (obj.UpperSurface(1,index) < leftMostPosition)
                    leftMostPosition = obj.UpperSurface(1,index);
                else
                    leftMostIndex = index - 1;
                    break;
                end
            end

            % If transfering is needed
            if (leftMostIndex > 1)
                % Store left most point vector for future reference
                leadingPoint = obj.UpperSurface(:,leftMostIndex);

                % Transfer upper surface points before and including the
                % left most point, but not the first point
                % to the lower surface
                obj.LowerSurface = [fliplr(obj.UpperSurface(:,2:leftMostIndex)) obj.LowerSurface];
                % Delete transfered points from the upper surface
                obj.UpperSurface = obj.UpperSurface(:,leftMostIndex:end);

                % Translate the three surfaces such that the left most
                % point is at the origin
                obj.UpperSurface = obj.UpperSurface - leadingPoint;
                obj.ChamberLine = obj.ChamberLine - leadingPoint;
                obj.LowerSurface = obj.LowerSurface - leadingPoint;
            end
        end

        function pointPair = ComputePointPair(obj, x)
            %COMPUTEPOINTPAIR Gets a pair of points for a position on the
            % airfoil. This returns a 2x3 matrix, with the first column
            % being the upper surface point, second column being the chamber line
            % and the second column being the lower surface point.

            % Using formulas on https://en.wikipedia.org/wiki/NACA_airfoil

            % Compute thickness
            yt = obj.T * 5 * (0.2969 * sqrt(x) - 0.1260 * x - 0.3516 * x ^ 2 + 0.2843 * x ^ 3 - 0.1015 * x ^ 4);

            % Check if the maximumChamber is non-zero
            if (obj.M > 0)

                % Compute chamber line
                if (x <= obj.P)
                    yc = obj.M * (2 * obj.P * x - x ^ 2) / obj.P ^ 2;
                else
                    yc = obj.M * ((1 - 2 * obj.P) + 2 * obj.P * x - x ^ 2) / (1 - obj.P) ^ 2;
                end

                % Compute derivative of chamber line
                if (x <= obj.P)
                    dycdx = 2 * obj.M * (obj.P - x) / obj.P ^ 2;
                else
                    dycdx = 2 * obj.M * (obj.P - x) / (1 - obj.P) ^ 2;
                end

                % Compute normal angle of chamber line
                theta = atan(dycdx);

                % Get x and y components of thickness 
                % (as thickness is normal to chamber)
                ytcost = yt * cos(theta);
                ytsint = yt * sin(theta);

                % Return upper, chamber, and lower point
                pointPair = [x - ytsint, x, x + ytsint; yc + ytcost, yc, yc - ytcost];

            else % If the chamber is zero, then use a simplified process
                pointPair = [x, 0, x; yt, 0, -yt];
            end
        end
    end
end