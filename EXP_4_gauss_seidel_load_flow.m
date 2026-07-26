%% EXPERIMENT 4 - Load Flow Analysis using Gauss-Seidel Method
% Requires: y_bus_formulation.m (in the same folder / on the path)
clc; clear;

% line_data = [from_bus  to_bus  R  X]
line_data = [1 2 0.01 0.03;
             1 3 0.02 0.04;
             2 3 0.0125 0.025];

% bus_data = [bus_number  bus_type  V  angle  Pg  Qg  Pd  Qd]
% bus_type: 1 = Slack, 2 = PV, 3 = PQ
bus_data = [1 1 1.05 0 0 0 0 0;
            2 2 1.04 0 2 0 0 0;
            3 3 1.00 0 0 0 4 2.5];

% Extracting bus data
n_bus = size(bus_data, 1);
bus_type = bus_data(:, 2);
V_specified = bus_data(:, 3);
Pg = bus_data(:, 5);
Qg = bus_data(:, 6);
Pd = bus_data(:, 7);
Qd = bus_data(:, 8);

% Y-bus formulation function call
y_bus = y_bus_formulation(line_data);
fprintf('Y-Bus:\n');
disp(y_bus);

% Initialising voltages (in complex form)
V = zeros(n_bus, 1);
for i = 1:n_bus
    V(i) = V_specified(i) + 0j;
end

% Gauss-Seidel exit conditions
tolerance = 1e-6;
max_iter = 100;

for iter = 1:max_iter
    fprintf('\n--- Iteration %d ---\n', iter);
    V_old = V;

    % Update voltages for PV and PQ buses
    for i = 2:n_bus
        sum_val = 0;
        for j = 1:n_bus
            if j ~= i
                sum_val = sum_val + y_bus(i,j) * V(j);
            end
        end

        if bus_type(i) == 2                     % PV bus
            % Calculate reactive power
            Q_calc = -imag(conj(V(i)) * (y_bus(i,i)*V(i) + sum_val));
            Qg(i) = Q_calc;

            % Update power injection
            P_net = Pg(i) - Pd(i);
            Q_net = Qg(i) - Qd(i);
            S_net = P_net + 1j*Q_net;

            % Calculating voltage
            V(i) = (1/y_bus(i,i)) * (conj(S_net)/conj(V(i)) - sum_val);

            % Maintain voltage magnitude -> for a PV bus the magnitude stays
            % fixed but the angle changes, hence V(i)/abs(V(i)) makes it a
            % unit vector (direction only) so just the angle gets updated
            V(i) = V_specified(i) * (V(i) / abs(V(i)));

        elseif bus_type(i) == 3                  % PQ bus
            P_net = Pg(i) - Pd(i);
            Q_net = Qg(i) - Qd(i);
            S_net = P_net + 1j*Q_net;
            V(i) = (1/y_bus(i,i)) * (conj(S_net)/conj(V(i)) - sum_val);
        end
    end

    % Print voltages for this iteration
    fprintf('Bus Voltages:\n');
    for i = 1:n_bus
        V_mag = abs(V(i));
        V_ang = angle(V(i)) * 180/pi;
        fprintf('  Bus %d: |V| = %.6f pu, Angle = %.4f degrees\n', i, V_mag, V_ang);
    end

    % Check convergence
    delta_V = abs(V - V_old);
    max_error = max(delta_V);
    fprintf('Error: %.8f \n', max_error);

    if max_error < tolerance
        fprintf('\n*** Converged in %d iterations ***\n', iter);
        break;
    end
end

if iter == max_iter
    fprintf('\nWarning: Did not converge in %d iterations\n', max_iter);
end

% Final Results
fprintf('\n\n========== FINAL RESULTS ==========\n');
fprintf('Bus Voltages:\n');
for i = 1:n_bus
    V_mag = abs(V(i));
    V_ang = angle(V(i)) * 180/pi;
    fprintf('Bus %d: |V| = %.4f pu, Angle = %.4f degrees\n', i, V_mag, V_ang);
end

% Calculating injected powers
fprintf('\nBus Injected Powers (P + jQ):\n');
S_inj = zeros(n_bus, 1);
for i = 1:n_bus
    I_inj = 0;
    for j = 1:n_bus
        I_inj = I_inj + y_bus(i,j) * V(j);
    end
    S_inj(i) = V(i) * conj(I_inj);
    fprintf('Bus %d: S = %.4f + j%.4f pu\n', i, real(S_inj(i)), imag(S_inj(i)));
end

%{
Final Results (from published output):
Bus 1: |V| = 1.0500 pu, Angle = 0.0000 degrees
Bus 2: |V| = 1.0400 pu, Angle = -0.4988 degrees
Bus 3: |V| = 0.9717 pu, Angle = -2.6964 degrees

Bus Injected Powers (P + jQ):
Bus 1: S = 2.1842 + j1.4085 pu
Bus 2: S = 2.0000 + j1.4618 pu
Bus 3: S = -4.0000 + j-2.5000 pu

Converged in 13 iterations.
%}
