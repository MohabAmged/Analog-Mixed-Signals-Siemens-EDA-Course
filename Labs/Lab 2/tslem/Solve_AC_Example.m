%The Function now Take Netlist and Frequency start and end and step as
%inputs beside the Node we want to plot againest frequency in as a bode
%plot and the function return symbolic and numric solution and the
%Frequency and the output values as a vector  

% cleaning the workspace, and cmd window
clear all;
clc;
% The First Netlist Solution (Over Damped)
% running the first SPICE netlist
fprintf('the first netlist:\n');
[sum,num,x,y]=Solve_AC_Circuit("Over Damped .cir",3,1,10,10000);
% The 2nd Netlist Solution (Critical Damped)
% running the 2nd SPICE netlist
fprintf('the 2nd netlist:\n');
[sum1,num1,x1,y1]=Solve_AC_Circuit("Critical Damped.cir",3,1,10,10000);

% The 3rd Netlist Solution (Under Damped) With peaking Q>0.707
% running the 3rd SPICE netlist
fprintf('the 3rd netlist:\n');
[sum2,num2,x2,y2]=Solve_AC_Circuit("Under Damped .cir",3,1,10,10000);

