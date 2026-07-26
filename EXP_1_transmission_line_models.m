%% EXPERIMENT 1 - Short, Medium and Long Transmission Line Analysis
clc; clear;

VRL = 400*10^3;
PR = 400*10^6;
pf = 0.9;
R = 0.01;
X = 0.1;
Y = 1.1*10^-6;
L_short = 20;
L_medium = 150;
L_long = 300;

VR = VRL / sqrt(3);
IR = PR / (sqrt(3)*VRL*pf);

fprintf('Receiving End Voltage (per phase): %.2f kV\n', VR/10^3);
fprintf('Receiving End Current: %.2f A\n', IR);

%% Short transmission Line
fprintf('\n---- Short Line (20 km) ----\n');
Rshort = R * L_short;
Xshort = X * L_short;
Zshort = Rshort + 1i*Xshort;

A = 1; D = 1; B = Zshort; C = 0;
abcd = [A B; C D];
vrir = [VR; IR];
vsis = abcd*vrir;
VS = vsis(1,1);
IS = vsis(2,1);

regulation = ((abs(VS)-VR)/VR)*100;
P_sending = 3*abs(VS)*abs(IS)*pf;
eff = (PR/P_sending)*100;

fprintf('VS = %.2f kV\n', abs(VS)/1e3);
fprintf('IS = %.2f A\n', abs(IS));
fprintf('Voltage Regulation = %.2f %%\n', regulation);
fprintf('Efficiency = %.2f %%\n', eff);

%% Medium transmission Line
fprintf('\n---- Medium Line (150 km) ----\n');
R_medium = R * L_medium;
X_medium = X * L_medium;
Z_medium = R_medium + 1i*X_medium;
Y_medium = 1i*Y*L_medium;

A = 1 + Z_medium*Y_medium/2;
D = A;
B = Z_medium;
C = Y_medium*(1 + Z_medium*Y_medium/4);
abcd = [A B; C D];
vrir = [VR; IR];
vsis = abcd*vrir;
VS = vsis(1,1);
IS = vsis(2,1);

regulation = (abs(VS)-VR)/VR*100;
P_sending = 3*abs(VS)*abs(IS)*pf;
eff = (PR/P_sending)*100;

fprintf('VS = %.2f kV\n', abs(VS)/1e3);
fprintf('IS = %.2f A\n', abs(IS));
fprintf('Voltage Regulation = %.2f %%\n', regulation);
fprintf('Efficiency = %.2f %%\n', eff);

%% Long transmission Line
fprintf('\n---- Long Line (300 km) ----\n');
R_long = R*L_long;
X_long = X*L_long;
Z_long = R+1i*X;
Y_long = 1i*Y*L_long;

gamma = sqrt(Z_long*Y_long);
Zc = sqrt(Z_long/Y_long);
A = cosh(gamma); D = A; B = Zc*sinh(gamma); C = sinh(gamma)/Zc;
abcd = [A B; C D];
vrir = [VR; IR];
vsis = abcd*vrir;
VS = vsis(1,1);
IS = vsis(2,1);

regulation = (abs(VS)-VR)/VR*100;
P_sending = 3*abs(VS)*abs(IS)*pf;
eff = (PR/P_sending)*100;

fprintf('VS = %.2f kV\n', abs(VS)/1e3);
fprintf('IS = %.2f A\n', abs(IS));
fprintf('Voltage Regulation = %.2f %%\n', regulation);
fprintf('Efficiency = %.2f %%\n', eff);

%{
Expected output:
Receiving End Voltage (per phase): 230.94 kV
Receiving End Current: 641.50 A

---- Short Line (20 km) ----
VS = 231.07 kV
IS = 641.50 A
Voltage Regulation = 0.06 %
Efficiency = 99.94 %

---- Medium Line (150 km) ----
VS = 231.82 kV
IS = 641.84 A
Voltage Regulation = 0.38 %
Efficiency = 99.57 %

---- Long Line (300 km) ----
VS = 230.94 kV
IS = 646.00 A
Voltage Regulation = 0.00 %
Efficiency = 99.30 %
%}
