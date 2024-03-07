classdef ImportProfile < Profile
    %IMPORTPROFILE Represents an imported 'Lednicer' data file
    %   This class reads data formatted in David Lednicer's airfoil profile
    %   format and readys it for further processing in yFoil. Added as part
    %   of yFoil version 1.1

    properties
        % Name of this profile
        Name {mustBeTextScalar} = "";
        Points {mustBeInteger} = 0;
    end

    methods
        function this = ImportProfile(source)
            %IMPORTPROFILE Construct an instance of this class
            %   Creates an instance of this class and imports the points
            %   from the provided file path. The data file must be in the
            %   Lednicer format.

            % Read data
            [~,this.Name,~] = fileparts(source);
            rawData = readmatrix(source);

            % Get format
            if (rawData(1,:) == [0,0])
                % Other format TBC
            else
                % Lednicer format
                % Find all (0,0) points, which represent the start of a
                % surface
                surfaceIndexes = find(rawData(:,1) .* rawData(:,2) == 0);
                % Get surfaces
                this.UpperSurface = rawData(surfaceIndexes(1):surfaceIndexes(2) - 1, :)';
                this.LowerSurface = rawData(surfaceIndexes(2):end, :)';
                % store the number of points
                this.Points = size(rawData,1) - 1;
            end
            %count = size(rawdata,1);
            %fprintf("Profile %s, %d points", name, count);
        end

        function stats = GetStats(obj)
            %GETSTATS Gets a string with information about this import
            stats = sprintf("%s (%d points)", obj.Name, obj.Points);
        end
    end
end