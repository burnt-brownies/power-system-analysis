%% EXPERIMENT 2 - To formulate Y-Bus by step-by-step method
clc; clear;

% Given Data: [from_bus  to_bus  R  X]
A = [1 2 0.01 0.15;
     1 3 0.02 0.25;
     1 4 0.03 0.35;
     2 3 0.03 0.35;
     3 4 0.01 0.15;
     4 5 0.04 0.50];

e_size = size(A);
e = e_size(1,1);                              % total number of elements
n = max(max(A(:,1)), max(A(:,2)));            % total number of buses

Ybus = zeros(n, n);

Z = A(:,3) + A(:,4) * 1i;                     % Z = R + jX
% b_by_2 = A(:,5) / 2;                        % (if line charging b is given, add this)
Y = 1./Z;

from_bus = A(:,1);

% Diagonal Elements
for i = 1:n
    for j = 1:e
        if from_bus(j) == i
            Ybus(i,i) = Ybus(i,i) + Y(j);     % + b_by_2(j)
        end
    end
end

% Off diagonal Elements
for k = 1:e
    from = from_bus(k);
    to = A(k,2);
    Ybus(from, to) = -Y(k);
    Ybus(to, from) = -Y(k);
end

disp('Y-Bus Matrix -');
disp(Ybus);

%{
Expected Output:
Y-Bus Matrix -
 Columns 1 through 4
 1.0036 -13.4480i -0.4425 + 6.6372i -0.3180 + 3.9746i -0.2431 + 2.8363i
 -0.4425 + 6.6372i 0.2431 - 2.8363i -0.2431 + 2.8363i 0.0000 + 0.0000i
 -0.3180 + 3.9746i -0.2431 + 2.8363i 0.4425 - 6.6372i -0.4425 + 6.6372i
 -0.2431 + 2.8363i 0.0000 + 0.0000i -0.4425 + 6.6372i 0.1590 - 1.9873i
  0.0000 + 0.0000i  0.0000 + 0.0000i  0.0000 + 0.0000i -0.1590 + 1.9873i
 Column 5
  0.0000 + 0.0000i
  0.0000 + 0.0000i
  0.0000 + 0.0000i
 -0.1590 + 1.9873i
  0.0000 + 0.0000i
%}
