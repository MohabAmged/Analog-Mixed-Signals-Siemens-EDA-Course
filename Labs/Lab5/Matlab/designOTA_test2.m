% OTA Design Script
% Write the SPECS
clear all;
AVDC =34; % complete the line to add the gain SPEC
GBW =100e6 ;% complete the line to add the GBW SPEC
CL = 500e-15;% complete the line to add the CL SPEC
specs = struct('AVDC', AVDC,... 
'CL', CL,...
'GBW', GBW);

OTA = designOTA2(specs);
% Print the solution
fprintf('**** OTA Design With Parastics and Tolarence 8 percent ****\n\n');
fprintf('Input Pair:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n    ViCM=%.4f V\n    Id=%.4f um \n\n',OTA.M1.L,OTA.M1.W,OTA.M1.VG,OTA.M1.ID*1e6);
fprintf('CM Load:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n    Id=%.4f um\n    \n\n',OTA.M3.L,OTA.M3.W,OTA.M3.ID*1e6);
fprintf('Tail Current Source:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n    Id=%.4f um\n    \n\n',OTA.M5.L,OTA.M5.W,OTA.M5.ID*1e6);

