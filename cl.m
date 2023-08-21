% Command Line interface for yFoil

%% Input
fprintf("This is the command line interface for yFoil\n");

% Ask for the four digit naca specifier 
% (see https://en.wikipedia.org/wiki/NACA_airfoil)
query = input("Enter 4-digit NACA code: ", "s");

%% Generate NACA Profile
% Create an instance of a NacaProfile with the specified query
naca = NacaProfile.GenerateFromDigits(query);

% Create a vector with the independent variable for the naca profile. 
% This creates a profile with 20 points. The .^ ensures the points are
% concentrated towards the left leading edge of the profile.
xPointVector = (0:0.05:1).^2;

% If an error occures in NacaProfile.GenerateFromDigits(), then the method
% returns empty. So check if it is empty, print error message, and stop
% execution.
if (isempty(naca))
    fprintf('Invalid NACA specifier. See https://en.wikipedia.org/wiki/NACA_airfoil\n');
    return
end

% Compute the surface of the profile with the specified xPositionVector
% resolution.
naca = ComputeSurface(naca, xPointVector);

%% Generate yFoil
% TBC

%% Output Preview

close all;
hold on;

% Ensure that the plot scale is square (so that there's no distortion)
daspect([1 1 1])

% Plot the upper surface and lower surface on same figure
plot(naca.UpperSurface(1,:), naca.UpperSurface(2,:), "Color","blue");
plot(naca.LowerSurface(1,:), naca.LowerSurface(2,:), "Color", "red");

hold off;

%% Output
% TBC
