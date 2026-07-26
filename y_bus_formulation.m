function Ybus = y_bus_formulation(line_data)
% Y_BUS_FORMULATION  Builds the bus admittance matrix (Y-Bus) using the
% step-by-step method, from line data.
%
%   line_data = [from_bus  to_bus  R  X]   (one row per line)
%
% This is the reusable function version of the logic from
% EXP_2_ybus_step_by_step.m, used by Experiments 4, 5, 6 and 7.

e = size(line_data, 1);                                   % number of lines
n = max(max(line_data(:,1)), max(line_data(:,2)));        % number of buses

Ybus = zeros(n, n);

Z = line_data(:,3) + line_data(:,4) * 1i;   % Z = R + jX
Y = 1 ./ Z;

from_bus = line_data(:,1);

% Diagonal and off-diagonal elements
for k = 1:e
    from = from_bus(k);
    to = line_data(k,2);
    Ybus(from, from) = Ybus(from, from) + Y(k);
    Ybus(to, to)     = Ybus(to, to) + Y(k);
    Ybus(from, to)   = Ybus(from, to) - Y(k);
    Ybus(to, from)   = Ybus(to, from) - Y(k);
end

end
