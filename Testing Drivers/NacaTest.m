classdef NacaTest < matlab.unittest.TestCase
    %NACADRIVER Run this test lass to verify function of NacaProfile
    % From https://au.mathworks.com/help/matlab/matlab_prog/write-simple-test-case-using-classes.html
    properties
        profiles
    end

    methods (TestClassSetup)
        % Shared setup for the entire test class
        function createProfiles(testCase)
            % Create three profiles to test with
            profileSyntaxes = ['0015';'2412';'4510'];
            testCase.profiles = NacaProfile.empty();
            for n = 1:size(profileSyntaxes,1)
                testCase.profiles(n) = NacaProfile.GenerateFromDigits(profileSyntaxes(n,:));
            end
        end
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods
        
        function InvalidSyntaxes(testCase)
            %INVALIDSYNTAX NacaProfile.GenerateFroDigits should return
            %empty if a 4-digit specificer is not used
            invalidInputs = ["","abc","123","281-","jneow2ne02","1.23"];
            for input = invalidInputs
                testCase.verifyEmpty(NacaProfile.GenerateFromDigits(char(input)));
            end
        end
        
        function ValidSyntaxes(testCase)
            % Check that all test profiles are NacaProfiles
            % (and implicitly profiles)
            testCase.assertInstanceOf(testCase.profiles(1),"Profile");
            expectedM = [0, 0.02, 0.04];
            expectedP = [0, 0.4, 0.5];
            expectedT = [0.15 0.12 0.10];
            for n = 1:length(testCase.profiles)
                testCase.assertInstanceOf(testCase.profiles(n),"NacaProfile");
                testCase.verifyEqual(testCase.profiles(n).M, expectedM(n));
                testCase.verifyEqual(testCase.profiles(n).P, expectedP(n));
                testCase.verifyEqual(testCase.profiles(n).T, expectedT(n));
            end
        end
        
        function GetName(testCase)
            % Check that GetName and GetDigits works as expected
            profileSyntaxes = ['0015';'2412';'4510'];
            for n = 1:length(testCase.profiles)
                testCase.assertEqual( ...
                    testCase.profiles(n).GetName(), ...
                    ['NACA ' profileSyntaxes(n,:)]);
                testCase.assertEqual( ...
                    testCase.profiles(n).GetDigits(), ...
                    profileSyntaxes(n,:));
            end
        end
        
        function ComputePointPairFunction(testCase)
            % Checks whether the compute point pair function
            % works as expected

            % For the three profiles 0015, 2412 and 4510
            % The expected points for 0.5 along the chord
            expectedUpperPoint = [0.5,0.5006,0.5;0.0662,0.0724,0.0841];
            expectedChambPoint = [0.5,0.5,0.5;0,0.0194,0.04];
            expectedLowerPoint = [0.5,0.4994,0.5;-0.0662,-0.0335,-0.0041];

            % For each profile
            for n = 1:length(testCase.profiles)
                % Generate point pair at 0.5 units
                pointPair = testCase.profiles(n).ComputePointPair(0.5);

                % Check if equal to 0.001 units
                testCase.verifyEqual(pointPair(:,1),expectedUpperPoint(:,n), "AbsTol", 0.001);
                testCase.verifyEqual(pointPair(:,2),expectedChambPoint(:,n), "AbsTol", 0.001);
                testCase.verifyEqual(pointPair(:,3),expectedLowerPoint(:,n), "AbsTol", 0.001);
            end
        end

        function ProfileExists(testCase)
            % Check that upper and lower surfaces exist and are of a valid
            % size

            for profile = testCase.profiles
                % Upper surface
                usSize = size(profile.UpperSurface);
                testCase.assertEqual(usSize(1),2);
                testCase.assertGreaterThan(usSize(2),2);   
                % lower surface
                lsSize = size(profile.LowerSurface);
                testCase.assertEqual(lsSize(1),2);
                testCase.assertGreaterThan(lsSize(2),2);   
            end
        end

        function ProfileLeadingPoint(testCase)
            % Leading point of all profiles should be zero
            % Check the leading point is at origin

            for profile = testCase.profiles
                % Check that leading point is at origin            
                testCase.assertEqual(profile.UpperSurface(:,1),[0;0]);
                testCase.assertEqual(profile.LowerSurface(:,1),[0;0]); 
                % Check that all points are after the previous point
                % i.e. that the surface is a function of y (yFoil, get it?)
                for n = 2:length(profile.UpperSurface)
                    testCase.assertGreaterThan(profile.UpperSurface(1,n),...
                        profile.UpperSurface(1,n - 1));
                end
                for n = 2:length(profile.LowerSurface)
                    testCase.assertGreaterThan(profile.LowerSurface(1,n),...
                        profile.LowerSurface(1,n - 1));
                end
            end
        end

        function ProfileThickness(testCase)                 
            % Check the thickness of each test profile
            for profile = testCase.profiles   
                % Get the highest point on the upper surface (as foil is
                % symmetrical)
                % Verify that maximum point is thickness/2 + chamber to a margin of 0.01 units
                maxUpperSurface = max(profile.UpperSurface(2,:));
                testCase.verifyEqual(maxUpperSurface, profile.M + profile.T/2, "AbsTol", 0.01);

                % If the chamber is zero (symmetrical), verify that lowest
                % point is -thickness/2
                if (profile.M == 0)
                    minLowerSurface = min(profile.LowerSurface(2,:));
                    testCase.verifyEqual(minLowerSurface, - profile.T/2, "AbsTol", 0.01);
                end
            end
        end
        
        function ProfileUpperSurface(testCase)
            % Check whether profile matches that generated by
            % https://www.desmos.com/calculator/ztfvbaewma:

            % The reference equations for the 0015, 2412 and 4510 airfoils
            % as generated (each row has one profile equation)
            expectedData = [0.234074,-0.141009,-0.13732,0.0464721;0.198684,-0.0418051,-0.218535,0.0637598;0.168348,0.0342502,-0.213983,0.0128187];

            % For each profile
            for n = 1:length(testCase.profiles)
                profile = testCase.profiles(n);
                coeff = expectedData(n,:);
                % Get the profile's upper surface, and translate to chamber
                % origin point
                actualSurface = profile.UpperSurface - profile.ChamberLine(:,1);
                % For each point in the surface, excluding first and last
                % points

                for actualPoint = actualSurface(:,2:end)
                    % Compute actual and expected point
                    X = actualPoint(1);
                    Y = actualPoint(2);
                    expY = coeff(1)*sqrt(X) + coeff(2)*X + coeff(3)*X^2 + coeff(4)*X^2;
                    % Check if within 0.01 units
                    testCase.assertEqual(Y, expY, "AbsTol", 0.01);
                end
            end
        end
        
        function ProfileLowerSurface(testCase)
            % Check whether profile matches that generated by
            % https://www.desmos.com/calculator/ztfvbaewma:

            % The reference equations for the 0015, 2412 and 4510 airfoils
            % as generated (each row has one profile equation)
            expectedData = [-0.234074,0.141009,0.13732,-0.0464721;-0.188506,0.21756,-0.0405119,0.010228;-0.155984,0.256252,-0.0747167,-0.0268028];
            % For each profile
            for n = 1:length(testCase.profiles)
                profile = testCase.profiles(n);
                coeff = expectedData(n,:);
                % Get the profile's lower surface, and translate to chamber
                % origin point
                actualSurface = profile.LowerSurface - profile.ChamberLine(:,1);
                % For each point in the surface, excluding first and last
                % points

                for actualPoint = actualSurface(:,2:end)
                    % Compute actual and expected point
                    X = actualPoint(1);
                    Y = actualPoint(2);
                    expY = coeff(1)*sqrt(X) + coeff(2)*X + coeff(3)*X^2 + coeff(4)*X^2;
                    % Check if within 0.01 units
                    testCase.assertEqual(Y, expY, "AbsTol", 0.01);
                end
            end
        end
        
        function ComputeSurfaceFunction(testCase)
            %CANRECOMPUTE checks if computed surface points can be
            %regenerated when properties change

            % Make a profile
            profile = NacaProfile.GenerateFromDigits('3310');

            % Modify it's parameters to '0010'
            profile.M = 0;
            profile.P = 0;

            % Recompute Surface
            profile.ComputeSurface();

            % Check if recomputed surface is ok:
            testCase.verifyEqual(profile.UpperSurface(:,1),[0;0]);
            maxUpperSurface = max(profile.UpperSurface(2,:));
            testCase.verifyEqual(maxUpperSurface, profile.T/2, "AbsTol", 0.01);
            minLowerSurface = min(profile.LowerSurface(2,:));
            testCase.verifyEqual(minLowerSurface, - profile.T/2, "AbsTol", 0.01);
        end
    end
end