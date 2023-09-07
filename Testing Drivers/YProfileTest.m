classdef YProfileTest < matlab.unittest.TestCase
    %NACADRIVER Run this test lass to verify function of NacaProfile
    % From https://au.mathworks.com/help/matlab/matlab_prog/write-simple-test-case-using-classes.html
    properties
        nacaProfiles
        profiles
    end

    methods (TestClassSetup)
        % Shared setup for the entire test class
        function createProfiles(testCase)
            % Create three profiles to test with
            profileSyntaxes = ['0015';'2412';'4510'];
            testCase.nacaProfiles = NacaProfile.empty();
            testCase.profiles = YProfile.empty();
            for n = 1:size(profileSyntaxes,1)
                testCase.nacaProfiles(n) = NacaProfile.GenerateFromDigits(profileSyntaxes(n,:));
                testCase.profiles(n) = YProfile(testCase.nacaProfiles(n));
            end
        end
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods

        function NotEmpty(testCase)
            % Check that coefficients and points exist
            for profile = testCase.profiles
                testCase.assertInstanceOf(profile, "YProfile");
                testCase.verifyNotEmpty(profile.UpperSurface);
                testCase.verifyNotEmpty(profile.LowerSurface);
                testCase.verifyNotEmpty(profile.UpperCoefficientsVector);
                testCase.verifyNotEmpty(profile.LowerCoefficientsVector);
            end
        end

        function UpperAndLowerSurfaceFunctions(testCase)
            % Check that the yFoil equation returns the right points for
            % upper and lower surfaces. The Get*SurfaceAt functions access
            % the private function ComputeY.

            % For the three profiles 0015, 2412 and 4510
            % The expected points for 0.5 along the chord
            expectedUpperPos = [0.0662,0.0724,0.0841];
            expectedLowerPos = [-0.0662,-0.0335,-0.0041];

            % For each profile
            for n = 1:length(testCase.profiles)
                % Check that function returns expected result to 0.003 units
                testCase.verifyEqual(testCase.profiles(n).GetUpperSurfaceAt(0.5), expectedUpperPos(n), "AbsTol", 0.003);
                testCase.verifyEqual(testCase.profiles(n).GetLowerSurfaceAt(0.5), expectedLowerPos(n), "AbsTol", 0.003);
            end
        end
        
        function ProfileLeadingPoint(testCase)
            % Leading point of all profiles should be zero
            % Check the leading point is at origin

            for profile = testCase.profiles
                usSize = size(profile.UpperSurface);
                testCase.verifyEqual(usSize(1),2);
                testCase.verifyGreaterThan(usSize(2),2);
                testCase.verifyEqual(profile.UpperSurface(:,1),[0;0]);
                testCase.verifyEqual(profile.LowerSurface(:,1),[0;0]);     
            end
        end

        function ProfileUpperSurface(testCase)
            % Check whether profile matches that generated by
            % https://www.desmos.com/calculator/ztfvbaewma:

            % The reference equations for the 0015, 2412 and 4510 airfoils
            % as generated (each row has one profile equation:)
            expectedData = [0.234074,-0.141009,-0.13732,0.0464721;0.198684,-0.0418051,-0.218535,0.0637598;0.168348,0.0342502,-0.213983,0.0128187];

            % For each profile
            for n = 1:length(testCase.profiles)
                profile = testCase.profiles(n);
                coeff = expectedData(n,:);
                % Get the profile's upper surface, and translate to chamber
                % origin point to undo the correction made when making the
                % reference naca profiles
                actualSurface = profile.UpperSurface - testCase.nacaProfiles(n).ChamberLine(:,1);

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
            % as generated (each row has one profile equation:)
            expectedData = [-0.234074,0.141009,0.13732,-0.0464721;-0.188506,0.21756,-0.0405119,0.010228;-0.155984,0.256252,-0.0747167,-0.0268028];

            % For each profile
            for n = 1:length(testCase.profiles)
                profile = testCase.profiles(n);
                coeff = expectedData(n,:);
                % Get the profile's upper surface, and translate to chamber
                % origin point to undo the correction made when making the
                % reference naca profiles
                actualSurface = profile.LowerSurface - testCase.nacaProfiles(n).ChamberLine(:,1);

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

        function MeetsMinumumUpperRSquaredValue(testCase)
            % Check that the r2 value of the surface (with respect to the
            % naca profile) is within limits

            % For each profile
            for n = 1:length(testCase.profiles)
                % Get X and Y points of the naca profile (the expected)
                X = testCase.nacaProfiles(n).UpperSurface(1,:);
                Y = testCase.nacaProfiles(n).UpperSurface(2,:);

                % Calculate equilavent points for the yFoil
                yCalc = testCase.profiles(n).GetUpperSurfaceAt(X);
                
                % Find R squared value (using formula at https://au.mathworks.com/help/matlab/data_analysis/linear-regression.html)
                r2 = 1 - sum((Y - yCalc).^2)/sum((Y - mean(Y)).^2);

                % Check that r@ greater than minimum
                testCase.verifyGreaterThanOrEqual(r2,testCase.profiles(n).MinimumQualityVector(1));
            end
        end

        function MeetsMinumumLowerRSquaredValue(testCase)
            % Check that the r2 value of the surface (with respect to the
            % naca profile) is within limits

            % For each profile
            for n = 1:length(testCase.profiles)
                % Get X and Y points of the naca profile (the expected)
                X = testCase.nacaProfiles(n).LowerSurface(1,:);
                Y = testCase.nacaProfiles(n).LowerSurface(2,:);

                % Calculate equilavent points for the yFoil
                yCalc = testCase.profiles(n).GetLowerSurfaceAt(X);
                
                % Find R squared value (using formula at https://au.mathworks.com/help/matlab/data_analysis/linear-regression.html)
                r2 = 1 - sum((Y - yCalc).^2)/sum((Y - mean(Y)).^2);

                % Check that r@ greater than minimum
                testCase.verifyGreaterThanOrEqual(r2,testCase.profiles(n).MinimumQualityVector(2));
            end
        end

        function Equations(testCase)
            % Checks whether the equations generated are computer-readable
            % and are corrrect

            SRFS = ['ux';'uy';'lx';'ly'];
            t = 0.25;
            chord = 2;

            % For each profile
            for profile = testCase.profiles
                % Generate and evaluate equations                
                resultVector = zeros(1,4);
                for n = 1:length(SRFS)
                    equation = profile.GetEquation(SRFS(n,:), 'chord');
                    resultVector(n) = eval(equation);
                end
                
                % Check if values match expected
                testCase.verifyEqual(resultVector(1), t*chord, "AbsTol", 0.00001);
                testCase.verifyEqual(resultVector(2), profile.GetUpperSurfaceAt(t)*chord, "AbsTol", 0.00001);
                testCase.verifyEqual(resultVector(3), t*chord, "AbsTol", 0.00001);
                testCase.verifyEqual(resultVector(4), profile.GetLowerSurfaceAt(t)*chord, "AbsTol", 0.00001);
            end
        end
    end
end