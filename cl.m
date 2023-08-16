% Command Line interface for yFoil
fprintf("This is the command line interface for yFoil\n");
query = input("Enter 4-digit NACA code:");
points = getPoints(1,2,3);
plot(points);