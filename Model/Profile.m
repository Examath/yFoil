classdef Profile < handle
    %PROFILE Represents a airfoil with upper and lower surface points
    %   This superclass contains properties storing a collection of points
    %   to make up upper and lower surfaces of a profile

    % This class inherits from handle, which ensures copies of the profile
    % are not made. Yes, I've done OOP before
    % See https://au.mathworks.com/help/matlab/matlab_oop/handle-objects.html

    properties % To be inherited by derived classes
        % A 2 by m matrix that stores the points forming the upper surface 
        % of the profile
        UpperSurface
        % A 2 by m matrix that stores the points forming the lower surface 
        % of the profile
        LowerSurface
    end

    methods
    end
end