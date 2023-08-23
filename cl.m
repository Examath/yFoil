% Command Line interface for yFoil

%% Input
fprintf("This is the command line interface for yFoil\n");

% Ask for the four digit naca specifier 
% (see https://en.wikipedia.org/wiki/NACA_airfoil)
query = input("Enter 4-digit NACA code: ", "s");

%% Generate NACA Profile
% Check if query is empty
if (~isempty(query))
    % Create an instance of a NacaProfile with the specified query
    naca = NacaProfile.GenerateFromDigits(query);
else
    % Create a default profile
    naca = NacaProfile.GenerateFromDigits('4412');
end

% Measure time taken to compute for performance
tic;

% Create a vector with the independent variable for the naca profile. 
% This creates a profile with 20 points. The .^ ensures the points are
% concentrated towards the left leading edge of the profile.
xPointVector = (0:0.05:1).^3;

% If an error occures in NacaProfile.GenerateFromDigits(), then the method
% returns empty. So check if it is empty, print error message 
% with a helpful link and stop execution.
if (isempty(naca))
    fprintf('Invalid NACA specifier ''%s''. See <a href="https://en.wikipedia.org/wiki/NACA_airfoil\n">Wikipedia: NACA Airfoil</a> for help on format.', query);
    return
end

% Compute the surface of the profile with the specified xPositionVector
% resolution.
naca = ComputeSurface(naca, xPointVector);

%% Generate yFoil
% TBC

%% Output Preview

% Create a new figure window
close all;
f = figure;
f.Position(3:4) = [800 500];
hold on;

% Ensure that the plot scale is square (so that there's no distortion)
daspect([1 1 1]);
% Set axes limits
xlim([-0.2 1.2]);
ylim([-0.4 0.4]);
% Display grid
grid on;
grid minor

% Plot the upper surface, chamber line and lower surface on same figure
plot(naca.UpperSurface(1,:), naca.UpperSurface(2,:), Color='b', Marker='.');
plot(naca.ChamberLine(1,:), naca.ChamberLine(2,:), Color='y');
plot(naca.LowerSurface(1,:), naca.LowerSurface(2,:), Color='r', Marker='.');

hold off;

%% Output
% TBC

% Print measured time taken
toc;
