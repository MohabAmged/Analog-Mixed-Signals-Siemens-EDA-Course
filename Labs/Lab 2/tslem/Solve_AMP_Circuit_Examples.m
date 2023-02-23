%The Function now Take Netlist and Frequency start and end and step as
%inputs beside the Node we want to plot againest frequency in as a bode
%plot and the function return symbolic and numric solution and the
%Frequency and the output values as a vector  

% cleaning the workspace, and cmd window
clear all;
clc;
% The First Netlist Solution Non_Inverting Amp with Unity gain
% configurations 
% running the first SPICE netlist
fprintf('the first netlist:\n');
[symbolic_ans , numeric_ans,Freq,yplot]=Solve_AMP_Circuit("Unity Gain_Non_InvAmp.cir",1,1,10,100e+6);




