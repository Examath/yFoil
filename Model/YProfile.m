classdef YProfile < Profile
    %YPROFILE Represents a yFoil Profile
    %   A yFoil aerofoil is determined by a series of coefficients. The
    %   geometry for both surfaces can be determined by the formula
    %       y(x) = c0*sqrt(x) + c1*x + c2*x^2 + ... + cN*x^N
    %   where c0, c1, ..., cN are the coefficients and N is some quality

    properties (Constant = true)
        % The maximum computed degree for the yFoil equation
        MAXIMUM_DEGREE = 8
    end
    
    properties
        % Stores the coefficients for the upper yFoil equation
        UpperCoefficients
        % Stores the coefficients for the lower yFoil equation
        LowerCoefficients
        % Stores the r2 value for the upper surface
        UpperR2
        % Stores the r2 value for the lower surface
        LowerR2
        % The minimum quality level (minimum r^2 value) for upper (1) and
        % lower (2) surfaces
        MinimumQuality
    end
    
    methods
        function obj = YProfile(profile, quality)
            %YPROFILE Construct an instance of this class from the NACA
            % profile
            %   This constructor creates a new yFoil from the specified
            %   profile with a specified quality.
            arguments
                % The profile to use for calculating surfaces
                profile (1,1) {mustBeA(profile,"NacaProfile")}
                % The minimum quality level (minimum r^2 value) for upper (1) and
                % lower (2) surfaces
                quality (1,2) = [0.9998, 0.99]
            end
            obj.MinimumQuality = quality;

            % For each surface            
            [obj.UpperCoefficients, obj.UpperR2] = ComputeCoefficients(obj, profile.UpperSurface, obj.MinimumQuality(1));
            [obj.LowerCoefficients, obj.LowerR2] = ComputeCoefficients(obj, profile.LowerSurface, obj.MinimumQuality(2));

            ComputeSurface(obj);
        end

        function equation = GetEquation(obj, id, chordName)
            %GETEQUATION Get a yFoil equation to use in Inventor
            arguments
                obj % The yProfile
                % Two characters specifing the surface (u or l) and
                % dimension (x or y) of the eqation
                id (1,2) {mustBeTextScalar} 
                % The parameter to scale equation by
                chordName {mustBeTextScalar}
            end

            if(id(2) == 'y') % Output y(t)

                % Choose surface
                if (id(1) == 'u')
                    coefficients = obj.UpperCoefficients;
                else
                    coefficients = obj.LowerCoefficients;
                end

                % Generate first and second terms
                equation = sprintf('%f*sqrt(t) %+f*t', coefficients(1), coefficients(2));

                % Generate other terms
                for n = 3:length(coefficients)
                    equation = sprintf('%s %+f*t^%d', equation, coefficients(n), n - 1);
                end

            else % Output x(t)
                equation = 't';
            end      
            
            % Scale profile by chord
            equation = sprintf('%s * (%s)', chordName, equation);
        end

        function y = GetUpperSurfaceAt(obj,x)
            %UPPERSURFACEAT Gets the y-value of the upper surface of the 
            % airfoil function at a specific point
            y = ComputeY(obj.UpperCoefficients, x);
        end

        function y = GetLowerSurfaceAt(obj,x)
            %UPPERSURFACEAT Gets the y-value of the upper surface of the 
            % airfoil function at a specific point
            y = ComputeY(obj.LowerCoefficients, x);
        end
    end

    methods (Access = protected)
        function [coefficients, r2] = ComputeCoefficients(obj, surface, quality)
            %METHOD1 This method computes the yFoil coefficients for a
            %given surface and target quality
            %   This method uses regression to calculate the yFoil
            %   coefficients with an r^2 value greater than quality

            % With y(x) = c0*sqrt(x) + c1*x + c2*x^2 + ... + cn*x^n
            % We need to create and solve a linear system as per
            % https://au.mathworks.com/help/matlab/ref/mldivide.html
            % to find the coefficients.

            % Let
            n = 1;                  % Starting Degree of yFoil equation
            m = size(surface, 2);   % Number of points
            r2 = 0;                 % R squared value
            X = surface(1,:)'; % Column vector with values x1, x2, ..., xm
            Y = surface(2,:)'; % Column vector with values y1, y2, ..., ym

            % Then Y = [sqrt(X), X, X^2, ..., X^n] * coefficients
            %      Y = A * coefficients

            % Create first special column of A, and preallocate the rest.
            A = [sqrt(X), zeros(m, obj.MAXIMUM_DEGREE + 1)];

            % For each non-special column
            for col = 1:obj.MAXIMUM_DEGREE
                A(:,col + 1) = X.^col;
            end

            % While sufficient quality has not been reached and n is not a
            % very high number
            while (r2 < quality && n <= obj.MAXIMUM_DEGREE)
                n = n + 1;

                % Find coefficients by solving the linear system to a
                % specific degree n
                % using the mldivide operator
                coefficients = A(:,1:n + 1)\Y;

                yCalc = ComputeY(coefficients, X);

                % Find R squared value (using formula at https://au.mathworks.com/help/matlab/data_analysis/linear-regression.html)
                r2 = 1 - sum((Y - yCalc).^2)/sum((Y - mean(Y)).^2);
            end
        end

        function ComputeSurface(obj, xPositions)
            %COMPUTESURFACE Compute the points that make up this surface
            arguments
                obj
                % The x-positions at which the surface points are generated
                xPositions = (0:0.01:1).^3; 
            end

            % Generate surface            
            obj.UpperSurface = [xPositions; ComputeY(obj.UpperCoefficients,xPositions)];
            obj.LowerSurface = [xPositions; ComputeY(obj.LowerCoefficients,xPositions)];
        end
    end
end

function y = ComputeY(coefficients, xPositionVecor)
    %GETY Solves the yFoil equation at x given the coefficients
    
    % Now, y(x) = c0*sqrt(x) + c1*x + c2*x^2 + ... + cn*x^n
    % Calculate first term:
    y = coefficients(1) * sqrt(xPositionVecor);
    
    % Calculate other terms,
    for n = 2:length(coefficients)
        y = y + coefficients(n) * xPositionVecor.^(n - 1);
    end
end

