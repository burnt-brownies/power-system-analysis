%% EXPERIMENT 8(b) - Economic Dispatch using Gradient Method (With Generator Limits)
clc; clear;

a = [500 400 200];         % Cost coefficient (Rs/hr)
b = [5.3 5.5 5.8];         % Linear term (Rs/MWh)
c = [0.004 0.006 0.009];   % Quadratic term (Rs/MW^2h)

Pmin = [200 150 100];
Pmax = [450 350 225];

Pd = 975;               % Total system demand (MW)
lambda = 6.0;           % Initial lambda (Rs/MWh)
tolerance = 0.001;
max_iter = 50;

fprintf('ECONOMIC DISPATCH USING GRADIENT METHOD\n');

for iter = 1:max_iter
    % Compute generator powers from lambda
    P1 = (lambda - b(1)) / (2 * c(1));
    P2 = (lambda - b(2)) / (2 * c(2));
    P3 = (lambda - b(3)) / (2 * c(3));
    P = [P1 P2 P3];

    % Apply generator limits
    for i = 1:3
        if P(i) < Pmin(i)
            P(i) = Pmin(i);
        elseif P(i) > Pmax(i)
            P(i) = Pmax(i);
        end
    end

    % Total generated power
    P_total = sum(P);

    % Power mismatch
    deltaP = Pd - P_total;

    % Check for convergence
    if abs(deltaP) < tolerance
        break;
    end

    % Update lambda (gradient update)
    denom = sum(1 ./ (2 * c));
    lambda = lambda + deltaP / denom;
end

C1 = a(1) + b(1)*P(1) + c(1)*P(1)^2;
C2 = a(2) + b(2)*P(2) + c(2)*P(2)^2;
C3 = a(3) + b(3)*P(3) + c(3)*P(3)^2;
Total_Cost = C1 + C2 + C3;

fprintf('\n RESULTS \n');
fprintf('Lambda (lambda) = %.4f Rs/MWh\n', lambda);
fprintf('Generator   Power (MW)   Cost (Rs/hr)\n');
fprintf('G1 -> %8.2f -> %10.2f\n', P(1), C1);
fprintf('G2 -> %8.2f -> %10.2f\n', P(2), C2);
fprintf('G3 -> %8.2f -> %10.2f\n', P(3), C3);
fprintf('Total Power = %.2f MW\n', sum(P));
fprintf('Total Cost = Rs %.2f/hr\n', Total_Cost);

%{
Expected Output:
ECONOMIC DISPATCH USING GRADIENT METHOD

 RESULTS
Lambda (lambda) = 9.4000 Rs/MWh
Generator   Power (MW)   Cost (Rs/hr)
G1 ->   450.00 ->    3695.00
G2 ->   325.00 ->    2821.24
G3 ->   200.00 ->    1720.00
Total Power = 975.00 MW
Total Cost = Rs 8236.24/hr
%}
