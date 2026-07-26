%% EXPERIMENT 6 - Fast Decoupled Load Flow Method
% Requires: y_bus_formulation.m (in the same folder / on the path)
clc; clear;

% Line Data = [from_bus  to_bus  R  X]
line_data = [1 2 0.07 0.15;
             1 3 0.06 0.1;
             1 4 0.08 0.25;
             2 4 0.04 0.1;
             3 4 0.04 0.2];

% Bus Data = [bus_no  Pi  Qi  Vi  delta]
bus_data = [1  0     0    1.05 0;
            2 -0.4  -0.15 1    0;
            3 -0.5  -0.4  1    0;
            4 -0.7  -0.2  1    0];

n_bus = size(bus_data, 1);

% Y bus formulation function call
y_bus = y_bus_formulation(line_data);
disp('Y-bus Matrix:');
disp(y_bus);

G = real(y_bus);
B = imag(y_bus);

% Finding B' and B''
B_prime = -B(2:end, 2:end);
B_d_Prime = -B(3:end, 3:end);

% Initial Values from Bus data
P = bus_data(:,2);
Q = bus_data(:,3);
V = bus_data(:,4);
delta = bus_data(:,5);

% Iteration loop
tol = 1e-4;
max_iter = 20;
iter = 0;

while true
    iter = iter + 1;
    Vm = V .* exp(1i*delta);                  % Build complex voltages

    S = zeros(n_bus, 1);                      % Calculating power injections
    for i = 2:n_bus
        YV = 0;
        for j = 1:n_bus
            YV = YV + y_bus(i,j)*Vm(j);
        end
        S(i,1) = Vm(i) * conj(YV);
    end

    % Calculating mismatches
    Pcal = real(S);
    Qcal = imag(S);
    Pmismatch = P - Pcal;
    Qmismatch = Q - Qcal;

    % Stop condition
    mismatch = [Pmismatch(2:end); Qmismatch(3:end)];
    if max(abs(mismatch)) < tol || iter >= max_iter
        break;
    end

    % Fast decoupled power flow updates
    pd = Pmismatch(2:end);      % deltaP excluding slack
    qd = Qmismatch(3:end);      % deltaQ excluding slack and PV

    del_delta = B_prime \ pd;
    delta(2:end) = delta(2:end) + del_delta

    del_v = B_d_Prime \ qd;
    V(3:end) = V(3:end) + del_v
end

%{
Expected Output (final converged values):
Y-bus Matrix:
 8.1276 -16.4558i -2.5547 + 5.4745i -4.4118 + 7.3529i -1.1611 + 3.6284i
 -2.5547 + 5.4745i 6.0030 -14.0951i 0.0000 + 0.0000i -3.4483 + 8.6207i
 -4.4118 + 7.3529i 0.0000 + 0.0000i 5.3733 -12.1606i -0.9615 + 4.8077i
 -1.1611 + 3.6284i -3.4483 + 8.6207i -0.9615 + 4.8077i 5.5709 -17.0568i

delta =
      0
 -0.0744
 -0.0457
 -0.0837

V =
 1.0500
 1.0000
 0.9732
 0.9802
%}
