% Command Line interface for yFoil

%% Input
fprintf("This is the command line interface for yFoil\n");

% Ask for the four digit naca specifier 
% (see https://en.wikipedia.org/wiki/NACA_airfoil)
query = input("Enter 4-digit NACA code (Default = 4412): ", "s");
% To scale the profile, a width parameter is needed in the equation
chordName = input('Enter chord parameter name to generate equations, or enter to continue: ', 's');

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
% This creates a profile with 20 points. The .^3 ensures the points are
% concentrated towards the left leading edge of the profile.
xPointVector = (0:0.05:1).^3;

% If an error occures in NacaProfile.GenerateFromDigits(), then the method
% returns empty. So check if it is empty, print error message 
% with a helpful link and stop execution.
if (isempty(naca))
    fprintf('Invalid NACA specifier ''%s''. See <a href="https://en.wikipedia.org/wiki/NACA_airfoil\n">Wikipedia: NACA Airfoil</a> for help on format.', query);
    return
end

% If not empty, then surface has been computed. 
% Indicate to user the quality of the surface, and how long it took to calculate:
fprintf('Generated %s with %d upper and %d lower surface points\n\t', GetName(naca), size(naca.UpperSurface,2), size(naca.LowerSurface,2));
toc;

%% Generate yFoil
tic;
yfoil = YProfile(naca, 0.999);
% Print some details
fprintf("Generated yFoil:\n");
fprintf("\tUpper surface [ %s]\n\t\t(r2 = %f)\n", sprintf('%f ', yfoil.UpperCoefficientsVector), yfoil.UpperR2);
fprintf("\tLower surface [ %s]\n\t\t(r2 = %f)\n\t", sprintf('%f ', yfoil.LowerCoefficientsVector), yfoil.LowerR2);
toc;

%% Output Preview
% Based primaraly of documentation: https://au.mathworks.com/help/matlab/ref/plot.html
% Create a new figure window
close all;
f = figure;
f.Position(3:4) = [800 500];
hold on;

% Ensure that the plot scale is square (so that there's no distortion)
daspect([1 1 1]);
% Set x-axes limit
xlim([-0.2 1.2]);
% Set y-axis limit
ylim([-ceil((naca.T / 2 + 0.05) * 10) / 10, ceil((naca.M + naca.T / 2 + 0.05) * 10) / 10]);
% Display grid
grid on;
grid minor

% Plot the upper surface, chamber line and lower surface of the NACA profile
% on same figure
plot(naca.UpperSurface(1,:), naca.UpperSurface(2,:), Color='m', Marker='.');
plot(naca.ChamberLine(1,:), naca.ChamberLine(2,:), Color='y');
plot(naca.LowerSurface(1,:), naca.LowerSurface(2,:), Color='m', Marker='.');

% Plot the yFoil
plot(yfoil.UpperSurface(1,:), yfoil.UpperSurface(2,:), Color='b');
plot(yfoil.LowerSurface(1,:), yfoil.LowerSurface(2,:), Color='b');

hold off;

%% Output Equation for Autodesk Inventor

% If user equations to be generated
if (~isempty(chordName))
    fprintf('\n======================== Equations ========================\n')
    SRFS =  ['ux';'uy';'lx';'ly'];
    for n = 1:length(SRFS)
        fprintf('\t%s\n%s\n', SRFS(n,:), yfoil.GetEquation(SRFS(n,:), chordName));
    end
    fprintf('===========================================================\n')
end