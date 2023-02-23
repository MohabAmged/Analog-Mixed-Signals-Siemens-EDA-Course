% OTA Design Script
% Write the SPECS
clear all;
AVDC = % complete the line to add the gain SPEC
GBW = % complete the line to add the GBW SPEC
CL = % complete the line to add the CL SPEC
specs = struct('AVDC', AVDC,... 
'CL', CL,...
'GBW', GBW);

OTA = designOTA(specs);
% Print the solution
fprintf('**** OTA Design ****\n\n');
fprintf('Input Pair:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n    ViCM=%.4f V\n\n',OTA.M1.L,OTA.M1.W,OTA.M1.VG);
fprintf('CM Load:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n\n',OTA.M3.L,OTA.M3.W);
fprintf('Tail Current Source:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n\n',OTA.M5.L,OTA.M5.W);

