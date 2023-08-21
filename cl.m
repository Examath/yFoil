% Command Line interface for yFoil

%% Input
fprintf("This is the command line interface for yFoil\n");
%query = input("Enter 4-digit NACA code:"); % No input for now

%% Generate NACA Profile
% Init default NACA
naca = NacaProfile;

% Plot the upper surface and lower surface on same figure
close all;
hold on;
plot(naca.UpperSurface(1,:), naca.UpperSurface(2,:), "Color","blue");
plot(naca.LowerSurface(1,:), naca.LowerSurface(2,:), "Color", "red");
hold off;

%% Generate yFoil

%% Output Preview

%% Output

% For now, fprintf the y of the upper, lower surfaces
fprintf('%.2f ', naca.UpperSurface(2,:));
fprintf('\n');
fprintf('%.2f ', naca.LowerSurface(2,:));
fprintf('\n');