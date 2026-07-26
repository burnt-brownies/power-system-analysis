%% EXPERIMENT 5 - Formation of the Jacobian Matrix (Newton-Raphson Load Flow)
% Requires: y_bus_formulation.m (in the same folder / on the path)
clc; clear;

% Line Data = [from_bus  to_bus  R  X]
line_data = [1 2 0.07 0.15;
             1 3 0.06 0.1;
             1 4 0.08 0.25;
             2 4 0.04 0.1;
             3 4 0.04 0.2];

% Bus Data = [bus_no  bus_type  Pi  Qi  Vi  delta]
% bus_type: 1 = Slack, 2 = PV, 3 = PQ
bus_data = [1 1  0     0    1.05 0;
            2 2 -0.4  -0.15 1    0;
            3 3 -0.5  -0.4  1    0;
            4 3 -0.7  -0.2  1    0];

% Y bus formulation function call
y_bus = y_bus_formulation(line_data);
disp('Y-bus Matrix:');
disp(y_bus);

G = real(y_bus);
B = imag(y_bus);
n_bus = size(y_bus, 1);

Pi = bus_data(:,3);
Qi = bus_data(:,4);
V = bus_data(:,5);
delta = bus_data(:,6);

% Determining number of PV and PQ buses
bus_type = bus_data(:,2);
pq_buses = find(bus_type == 3);
pv_buses = find(bus_type == 2);
npv = sum(bus_type == 2);
npq = sum(bus_type == 3);

% Initializing Jacobian matrix blocks
H = zeros(n_bus-1, n_bus-1);   % 3x3: dP/d(delta)
N = zeros(n_bus-1, npq);       % 3x2: dP/dV (only PQ bus voltages)
J = zeros(npq, n_bus-1);       % 2x3: dQ/d(delta) (only PQ bus equations)
L = zeros(npq, npq);           % 2x2: dQ/dV (only PQ buses)

% Filling H and N matrices
for i = 2:n_bus                       % Skipping slack bus
    row_idx = i - 1;
    for j = 2:n_bus
        col_idx = j - 1;
        if i == j
            % Diagonal Elements for H
            H(row_idx, col_idx) = -Qi(i) - (B(i,i) * V(i)^2);
        else
            % Off-diagonal elements for H
            H(row_idx, col_idx) = abs(V(i)*V(j)) * ...
                (G(i,j)*sin(delta(i)-delta(j)) - B(i,j)*cos(delta(i)-delta(j)));
        end
    end

    for k = 1:npq
        pq_bus = pq_buses(k);
        if i == pq_bus
            % Diagonal Elements for N
            N(row_idx, k) = Pi(i) + (G(i,i) * V(i)^2);
        else
            % Off-diagonal elements for N
            N(row_idx, k) = abs(V(i)*V(pq_bus)) * ...
                (G(i,pq_bus)*cos(delta(i)-delta(pq_bus)) + B(i,pq_bus)*sin(delta(i)-delta(pq_bus)));
        end
    end
end

% Filling J and L matrices
for m = 1:npq
    i = pq_buses(m);
    row_idx = m;
    for j = 2:n_bus
        col_idx = j - 1;
        if i == j
            % Diagonal Elements for J
            J(row_idx, col_idx) = Pi(i) - (G(i,i) * V(i)^2);
        else
            % Off-diagonal elements for J
            J(row_idx, col_idx) = -abs(V(i)*V(j)) * ...
                (G(i,j)*cos(delta(i)-delta(j)) + B(i,j)*sin(delta(i)-delta(j)));
        end
    end

    for n = 1:npq
        pq_bus_col = pq_buses(n);
        col_idx = n;
        if i == pq_bus_col
            % Diagonal Elements for L
            L(row_idx, col_idx) = Qi(i) - (B(i,i) * V(i)^2);
        else
            % Off-diagonal elements for L
            L(row_idx, col_idx) = abs(V(i)*V(pq_bus_col)) * ...
                (G(i,pq_bus_col)*sin(delta(i)-delta(pq_bus_col)) - B(i,pq_bus_col)*cos(delta(i)-delta(pq_bus_col)));
        end
    end
end

jacobian_matrix = [H N;
                   J L];
disp('Jacobian matrix:');
disp(jacobian_matrix);

%{
Expected Output:
Y-bus Matrix:
 8.1276 -16.4558i -2.5547 + 5.4745i -4.4118 + 7.3529i -1.1611 + 3.6284i
 -2.5547 + 5.4745i 6.0030 -14.0951i 0.0000 + 0.0000i -3.4483 + 8.6207i
 -4.4118 + 7.3529i 0.0000 + 0.0000i 5.3733 -12.1606i -0.9615 + 4.8077i
 -1.1611 + 3.6284i -3.4483 + 8.6207i -0.9615 + 4.8077i 5.5709 -17.0568i

Jacobian matrix:
 14.2451       0  -8.6207        0  -3.4483
       0 12.5606  -4.8077   4.8733  -0.9615
 -8.6207 -4.8077  17.2568  -0.9615   4.8709
       0 -5.8733   0.9615  11.7606  -4.8077
  3.4483  0.9615  -6.2709  -4.8077  16.8568
%}
