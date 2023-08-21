classdef NacaProfile
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        % Lower and Upper surface stores the 2d points that make up the
        % profile. They may not be the same size.
        UpperSurface
        LowerSurface
    end

    methods
        function this = NacaProfile(xPositions)
            %NacaFoil Construct and generate an instance of the profile
            %   This constructor generates a profle with the equation
            %   y = +-x^2
            arguments
                % This, per matlab documentation, should ensure parameter
                % is a vector and ensure
                % it to a default of 0.1 intervals
                xPositions {mustBeVector} = [0:0.1:1]
            end

            % Preallocate
            this.UpperSurface = zeros(2,length(xPositions));
            this.LowerSurface = zeros(2,length(xPositions));

            % To generate surface, loop through the provided x-positions
            % and generate respective point on both surfaces:
            for index = 1:length(xPositions)
                % In the real NACA curve, the x pos is complexly defined
                % But for now just assign
                this.UpperSurface(1, index) = xPositions(index);
                this.LowerSurface(1, index) = xPositions(index);
                
                % Creates a quadratic surface
                this.UpperSurface(2, index) = xPositions(index) ^ 2;
                this.LowerSurface(2, index) = - xPositions(index) ^ 2;
            end
        end

        % Part of template, not needed for now
        % function outputArg = method1(obj,inputArg)
        %     %METHOD1 Summary of this method goes here
        %     %   Detailed explanation goes here
        %     outputArg = obj.Property1 + inputArg;
        % end
    end
end