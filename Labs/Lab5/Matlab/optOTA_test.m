% OTA Design Script
% Write the SPECS
clear all;
AVDC = 34; %dB
GBW = 1e8; %Hz
CL = 500e-15; %Farad
specs = struct('AVDC', AVDC,... 
'CL', CL,...
'GBW', GBW);

OTA = loptOTA(specs);
% Print the solution
fprintf('**** Local opt OTA Design ****\n\n');
fprintf('Input Pair:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n    ViCM=%.4f V\n\n',OTA.M1.L,OTA.M1.W,OTA.M1.VG);
fprintf('CM Load:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n\n',OTA.M3.L,OTA.M3.W);
fprintf('Tail Current Source:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n    ID=%.2f um \n\n',OTA.M5.L,OTA.M5.W,OTA.M5.ID*1e6);

% Print the solution Global Opt
OTA2 = goptOTA(specs);

fprintf('**** Global opt OTA Design ****\n\n');
fprintf('Input Pair:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n    ViCM=%.4f V\n\n',OTA2.M1.L,OTA2.M1.W,OTA2.M1.VG);
fprintf('CM Load:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n\n',OTA2.M3.L,OTA2.M3.W);
fprintf('Tail Current Source:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n    ID=%.2f um \n\n',OTA2.M5.L,OTA2.M5.W,OTA2.M5.ID*1e6);



%% 