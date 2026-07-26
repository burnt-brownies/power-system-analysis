%% EXPERIMENT 3 - To formulate Ybus by Singular Transformation Method
clc; clear;

% Given Data: [from_bus  to_bus  R  X]
given = [1 2 0.01 0.15;
         1 3 0.02 0.25;
         1 4 0.03 0.35;
         2 3 0.03 0.35;
         3 4 0.01 0.15;
         4 5 0.04 0.50];

e_size = size(given);
e = e_size(1,1);                                  % total number of elements
n = max(max(given(:,1)), max(given(:,2)));        % total number of buses

A = zeros(e, n);                                  % Bus incidence matrix
from_bus = given(:,1);
to_bus = given(:,2);

for i = 1:e
    A(i, from_bus(i)) = 1;                        % Set incidence for from bus
    A(i, to_bus(i)) = -1;                         % Set incidence for to bus
end

disp('Bus Incidence Matrix -')
disp(A)

Z = given(:,3) + given(:,4) * 1i;                 % Z = R + jX
Y = 1./Z;

Ybus = A' * diag(Y) * A;

disp('Y-Bus Matrix -')
disp(Ybus)

%{
Expected Output:
Bus Incidence Matrix -
 1 -1  0  0  0
 1  0 -1  0  0
 1  0  0 -1  0
 0  1 -1  0  0
 0  0  1 -1  0
 0  0  0  1 -1

Y-Bus Matrix -
 Columns 1 through 4
 1.0036 -13.4480i -0.4425 + 6.6372i -0.3180 + 3.9746i -0.2431 + 2.8363i
 -0.4425 + 6.6372i 0.6856 - 9.4735i -0.2431 + 2.8363i 0.0000 + 0.0000i
 -0.3180 + 3.9746i -0.2431 + 2.8363i 1.0036 -13.4480i -0.4425 + 6.6372i
 -0.2431 + 2.8363i 0.0000 + 0.0000i -0.4425 + 6.6372i 0.8446 -11.4608i
  0.0000 + 0.0000i  0.0000 + 0.0000i  0.0000 + 0.0000i -0.1590 + 1.9873i
 Column 5
  0.0000 + 0.0000i
  0.0000 + 0.0000i
  0.0000 + 0.0000i
 -0.1590 + 1.9873i
  0.1590 - 1.9873i
%}
