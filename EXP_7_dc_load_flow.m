%% EXPERIMENT 7 - DC Load Flow Analysis
% Requires: y_bus_formulation.m (in the same folder / on the path)
clc; clear;

% Form Ybus matrix
zData = [1 2 0.07 0.15;
         1 3 0.06 0.1;
         1 4 0.08 0.25;
         2 4 0.04 0.1;
         3 4 0.04 0.2];

Ybus = y_bus_formulation(zData);
disp('Y-bus Matrix:');
disp(Ybus);

% bus_data = [bus_no  bus_type  V  angle  P  Q  index]
bus_data = [1 1 1.05 0.00  0.00  0.00 1;
            2 2 1.00 0.00 -0.40 -0.15 2;
            3 3 1.00 0.00 -0.50 -0.40 3;
            4 3 1.00 0.00 -0.70 -0.20 4];

G = real(Ybus);
B = imag(Ybus);
disp(B);

nbus = size(Ybus, 1);

% Initialize voltage magnitude and angle
V = bus_data(:,3);
delta = bus_data(:,4);

% Identify bus types
bus_type = bus_data(:,2);
pq_buses = find(bus_type == 3);
npq = length(pq_buses);
npv = sum(bus_type == 2);

P_i = bus_data(:,5);
Q_i = bus_data(:,6);

% Finding B' and B'' for FDLF
disp('B matrix');
disp(B);

% Forming the B prime matrix
B_prime = -B(2:end, 2:end);
disp('B prime ');
disp(B_prime);

% Calculate B double prime matrix
B_double_prime = -B(npq+1:end, npq+1:end);
disp('B double prime');
disp(B_double_prime);

%% Starting DC Load Flow Analysis
disp('DC LOAD FLOW ANALYSIS');
P_inj = bus_data(:,5);
B_reduced = B_prime;
Q_i = bus_data(:,6);

% Solve: theta = -B^(-1) * P
theta = zeros(nbus, 1);
theta(2:end) = inv(B_reduced) * P_inj(2:end);
disp('Angles:');
disp(theta);

fprintf('\n\nCalculating Real Power Flows\n\n');
P1G = 0;                                  % Initialize slack bus generation
P_flows = zeros(size(zData,1), 1);

for i = 1:size(zData,1)
    from = zData(i,1);
    to = zData(i,2);
    X_line = zData(i,4);
    P_flow = (V(from) * V(to) / X_line) * sin(theta(from) - theta(to));
    P_flows(i) = P_flow;
    fprintf('Line %d (Bus %d->%d): P%d%d = %.4f pu\n', i, from, to, from, to, P_flow);

    % Calculate slack bus generation (bus 1)
    if from == 1
        P1G = P1G + P_flow;
    elseif to == 1
        P1G = P1G - P_flow;
    end
end

% Display slack bus generation
fprintf('\n\nSlack Bus Power Generation\n\n');
fprintf('P1 (generation) = P12 + P13 + P14\n');
fprintf('P1 = %.4f + %.4f + %.4f = %.4f pu\n', P_flows(1), P_flows(2), P_flows(3), P1G);

fprintf('\n\nReactive Power Calculations\n\n');
Q_calc = zeros(nbus, 1);
for i = 1:nbus
    Q_calc(i) = -V(i)^2 * abs(Ybus(i,i)) * cos(angle(Ybus(i,i)));
    for k = 1:nbus
        if k ~= i
            Q_calc(i) = Q_calc(i) + V(i) * V(k) * abs(Ybus(i,k)) * ...
                cos(angle(Ybus(i,k)) + theta(k) - theta(i));
        end
    end
end

fprintf('Calculated Reactive Power Injections:\n');
for i = 1:nbus
    fprintf('Q%d = %.4f pu\n', i, Q_calc(i));
end

fprintf('\n\nLINE FLOW RESULTS:\n');
fprintf('Line | From-To | Power Flow (pu) | Angle Diff (deg)\n');
line_num = 1;
for i = 1:size(zData,1)
    from = zData(i,1);
    to = zData(i,2);
    fprintf(' %d | %d->%d | %.4f | %.4f\n', ...
        line_num, from, to, P_flows(i), rad2deg(theta(from)-theta(to)));
    line_num = line_num + 1;
end

%{
Expected Output (selected):
Angles:
      0
 -0.0991
 -0.0868
 -0.1156

Line 1 (Bus 1->2): P12 = 0.6923 pu
Line 2 (Bus 1->3): P13 = 0.9104 pu
Line 3 (Bus 1->4): P14 = 0.4843 pu
Line 4 (Bus 2->4): P24 = 0.1651 pu
Line 5 (Bus 3->4): P34 = 0.1438 pu

P1 = 0.6923 + 0.9104 + 0.4843 = 2.0870 pu
%}
