% cleaning the workspace, and cmd window
clear all;
clc;

% running the first SPICE netlist
fprintf('the first netlist:\n');
[sum,num]=Solve_Circuit('circuit_1.cir');

%clear all; % used to bypass an error only with Octave (not MATLAB)


fprintf('the second netlist:\n');
[sum1,num2]=Solve_Circuit('circuit_2.cir');
% add a line here to run the second netlist