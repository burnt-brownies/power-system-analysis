%% EXPERIMENT 8(a) - Economic Dispatch using Gradient Method (Without Limits)
clc; clear;

% Cost coefficients: Cost = a + b*P + c*P^2
a = [500 400 200];
b = [5.3 5.5 5.8];
c = [0.004 0.006 0.009];

% System parameters
Pd = 800;               % Total demand in MW
lambda = 6.0;           % Initial lambda value
tolerance = 0.001;      % Convergence tolerance
max_iter = 100;

fprintf('Economic Dispatch using Gradient Method\n');

for iter = 1:max_iter
    P1 = (lambda - b(1)) / (2*c(1));
    P2 = (lambda - b(2)) / (2*c(2));
    P3 = (lambda - b(3)) / (2*c(3));
    P_total = P1 + P2 + P3;

    % Finding delta P
    deltaP = Pd - P_total;      % Difference between demand and total power

    % Check convergence
    if abs(deltaP) < tolerance
        fprintf('Converged in %d iterations\n\n', iter);
        break;
    end

    % Update lambda using gradient
    denominator = sum(1 ./ (2 * c));   % summation 1/(2*gamma)
    lambda = lambda + deltaP / denominator;
end

% Calculate final costs
C1 = a(1) + b(1)*P1 + c(1)*P1^2;
C2 = a(2) + b(2)*P2 + c(2)*P2^2;
C3 = a(3) + b(3)*P3 + c(3)*P3^2;
Total_Cost = C1 + C2 + C3;

% Display results
fprintf('Results:\n');
fprintf('Lambda = %.1f Rs/MWh\n\n', lambda);
fprintf('Generator 1: P1 = %.2f MW, Cost = Rs%.2f/hr\n', P1, C1);
fprintf('Generator 2: P2 = %.2f MW, Cost = Rs%.2f/hr\n', P2, C2);
fprintf('Generator 3: P3 = %.2f MW, Cost = Rs%.2f/hr\n', P3, C3);
fprintf('\nTotal Power = %.2f MW\n', P1+P2+P3);
fprintf('Total Cost = Rs%.2f/hr\n', Total_Cost);

%{
Expected Output:
Economic Dispatch using Gradient Method
Converged in 2 iterations

Results:
Lambda = 8.5 Rs/MWh

Generator 1: P1 = 400.00 MW, Cost = Rs3260.00/hr
Generator 2: P2 = 250.00 MW, Cost = Rs2150.00/hr
Generator 3: P3 = 150.00 MW, Cost = Rs1272.50/hr

Total Power = 800.00 MW
Total Cost = Rs6682.50/hr
%}
