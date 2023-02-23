function [symbolic_ans , numeric_ans,Freq,yplot] = Solve_AMP_Circuit(netlist_directory,Plot_Node,Freq_Start,Freq_Step,Freq_Stop)

%{The Function Takes The netlist As input and the output node and the Frequency Range  
% we want to plot, The Step is how many points we want per decade , The functio have support 
% for VCCS and VCVS AC Linear Elments Support as well Modified The parse netlist function so 
% we can parse The VCCS and VCVS , The function Return Sympolic answers and Numeric and 
% plots The Output Vs freq and Return Both The Frequency Points And Output Points 

% note :
% when this function called , It return The frequency and The output as
% vectors so we could plot them in the way we want beside plotting the output
% vs frequency As a Bode Plot 
%}

%{
Part 1: reading the netlist
Part 2: parsing the netlist
Part 3: creating the matrices
Part 4: solving the matrices
%}

%__Part 1__

%loading netlist
raw_netlist = fopen(netlist_directory);
raw_netlist = fscanf(raw_netlist, '%c');

%Deleting multiple spaces, etc. using regular expressions
netlist = regexprep(raw_netlist,' *',' ');
netlist = regexprep(netlist,' I','I');
netlist = regexprep(netlist,' R','R');
netlist = regexprep(netlist,' V','V');
netlist = regexprep(netlist,' C','C');
netlist = regexprep(netlist,' L','L');
netlist = regexprep(netlist,' G','G');
netlist = regexprep(netlist,' E','E');
netlist = regexp(netlist,'[^\n]*','match');

%__Part 2__
%You may visit "ParseNetlist.m"
[R_Node_1 R_Node_2 R_Values R_Names] = ParseNetlist(netlist, 'R');
[V_Node_1 V_Node_2 V_Values V_Names] = ParseNetlist(netlist, 'V');
[I_Node_1 I_Node_2 I_Values I_Names] = ParseNetlist(netlist, 'I');
[C_Node_1 C_Node_2 C_Values C_Names] = ParseNetlist(netlist, 'C');
[L_Node_1 L_Node_2 L_Values L_Names] = ParseNetlist(netlist, 'L');
[G_Node_1 G_Node_2 G_Node_C1 G_Node_C2 G_Values G_Names] = ParseNetlist_Amp(netlist, 'G');
[E_Node_1 E_Node_2 E_Node_C1 E_Node_C2 E_Values E_Names] = ParseNetlist_Amp(netlist, 'E');
%Counting nodes
%Nodes should be named in order 0, 1, 2, 3, ..
%We will combine all parsed nodes, then find the maximum number which is
%the number of nodes assuming that they are named in order

nodes_list = [R_Node_1 R_Node_2 V_Node_1 V_Node_2 I_Node_1 I_Node_2 C_Node_1 C_Node_2 L_Node_1 L_Node_2 G_Node_1 G_Node_2 G_Node_C1 G_Node_C2 E_Node_1 E_Node_2 E_Node_C1 E_Node_C2 E_Names];
nodes_number = max(str2double(nodes_list));


%__Part 3__
%Matrices_size = no. nodes + no. Vsources + no.VCVS
matrices_size = nodes_number + numel(V_Names)+ numel(E_Names);

%Z matrix
%Initialize zero matrix
unit_matrix = cell(matrices_size, 1);
for i = 1:1:numel(unit_matrix)
    unit_matrix{i} = ['0'];
end
z = unit_matrix;

%stamping Isources
for I = 1:1:numel(I_Names)
    current_node_1 = str2double(I_Node_1(I));
    current_node_2 = str2double(I_Node_2(I));
    current_name = I_Names{I};
    if current_node_1 ~= 0
        z{current_node_1} = [z{current_node_1} '-' current_name];
    end
    if current_node_2 ~= 0
        z{current_node_2} = [z{current_node_2} '+' current_name];
    end
end
%stamping Vsources
for V = 1:1:numel(V_Names)
    z{nodes_number + V} = [V_Names{V}];
end
% adding Current Variable for VCVS 
% for E = 1:1:numel(E_Names)
%     z{nodes_number + numel(V_Names)+E } = [E_Names{E}];
% end

Z=str2sym(z);
    
%X matrix
x = cell(matrices_size, 1);
for node = 1:1:nodes_number
    x{node} = ['V_' num2str(node)];
end
%Stamping Vsources
for V = 1:1:numel(V_Names)
    x{nodes_number + V} = ['I_' V_Names{V}];
end
% Stamping VCVS
for E = 1:1:numel(E_Names)
    x{nodes_number + numel(V_Names) + E} = ['I_' E_Names{E}];
end
 
X = str2sym(x);

%A matrix
%_G matirix
G = repmat(unit_matrix(1:nodes_number),1, nodes_number);
%Stamping R
for R = 1:1:numel(R_Names)
    current_node_1 = str2double(R_Node_1(R));
    current_node_2 = str2double(R_Node_2(R));
    current_name = R_Names{R};
    if current_node_1 ~= 0
        G{current_node_1, current_node_1} = [G{current_node_1, current_node_1} '+1/' current_name];
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in G matrix
         G{current_node_2, current_node_2} = [G{current_node_2, current_node_2} '+1/' current_name];
    end
    if current_node_1 ~= 0 && current_node_2 ~= 0
        % add a line here to assign an element in G matrix
          G{current_node_1, current_node_2} = [G{current_node_1, current_node_2} '-1/' current_name];
        % add a line here to assign an element in G matrix
          G{current_node_2, current_node_1} = [G{current_node_2, current_node_1} '-1/' current_name];
    end
end

% Adding C to The G matrix 

for C = 1:1:numel(C_Names)
    current_node_1 = str2double(C_Node_1(C));
    current_node_2 = str2double(C_Node_2(C));
    current_name = C_Names{C};
    if current_node_1 ~= 0
        G{current_node_1, current_node_1} = [G{current_node_1, current_node_1} '+(i*W)*' current_name];
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in G matrix
         G{current_node_2, current_node_2} = [G{current_node_2, current_node_2} '+(i*W)*' current_name];
    end
    if current_node_1 ~= 0 && current_node_2 ~= 0
        % add a line here to assign an element in G matrix
          G{current_node_1, current_node_2} = [G{current_node_1, current_node_2} '-(i*W)*' current_name];
        % add a line here to assign an element in G matrix
          G{current_node_2, current_node_1} = [G{current_node_2, current_node_1} '-(i*W)*' current_name];
    end
end

% Adding L to The G matrix 

for L = 1:1:numel(L_Names)
    current_node_1 = str2double(L_Node_1(L));
    current_node_2 = str2double(L_Node_2(L));
    current_name =L_Names{L};
    if current_node_1 ~= 0
        G{current_node_1, current_node_1} = [G{current_node_1, current_node_1} '+(1/(i*W))/' current_name];
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in G matrix
         G{current_node_2, current_node_2} = [G{current_node_2, current_node_2} '+(1/(i*W))/' current_name];
    end
    if current_node_1 ~= 0 && current_node_2 ~= 0
        % add a line here to assign an element in G matrix
          G{current_node_1, current_node_2} = [G{current_node_1, current_node_2} '-(1/(i*W))/' current_name];
        % add a line here to assign an element in G matrix
          G{current_node_2, current_node_1} = [G{current_node_2, current_node_1} '-(1/(i*W))/' current_name];
    end
end

% Adding Gm to The G matrix 

for g = 1:1:numel(G_Names)
    current_node_1 = str2double(G_Node_1(g));
    current_node_2 = str2double(G_Node_2(g));
    Control_node_1 = str2double(G_Node_C1(g));
    Control_node_2 = str2double(G_Node_C2(g));
    current_name =G_Names{g};
    if current_node_1 ~= 0 && Control_node_1 ~= 0
        G{current_node_1, Control_node_1} = [G{current_node_1, Control_node_1} '+' current_name];
    end
    if current_node_2 ~= 0 && Control_node_2 ~= 0
        % add a line here to assign an element in G matrix
         G{current_node_2, Control_node_2} = [G{current_node_2, Control_node_2} '+' current_name];
    end
    if current_node_1 ~= 0 && Control_node_2 ~= 0 
        % add a line here to assign an element in G matrix
          G{current_node_1, Control_node_2} = [G{current_node_1, Control_node_2} '-' current_name];
    end
     if current_node_2 ~= 0 && Control_node_1 ~= 0
        % add a line here to assign an element in G matrix
         G{current_node_2, Control_node_1} = [G{current_node_2, Control_node_1} '-' current_name];
     end
    
   
end




%B matrix
B = repmat(unit_matrix, 1, numel(E_Names)+numel(V_Names));
%Stamping Vsource
for V = 1:1:numel(V_Names)
    current_node_1 = str2double(V_Node_1(V));
    current_node_2 = str2double(V_Node_2(V));
    if current_node_1 ~= 0
        % add a line here to assign an element in B matrix
     B{current_node_1,V} ='+1';
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in B matrix
        B{current_node_2,V} ='-1';
    end
end
%Stamping VCVS
for E = 1:1:numel(E_Names)
    current_node_1 = str2double(E_Node_1(E));
    current_node_2 = str2double(E_Node_2(E));
    if current_node_1 ~= 0
        % add a line here to assign an element in B matrix
     B{current_node_1,E+numel(V_Names)} ='+1';
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in B matrix
        B{current_node_2,E+numel(V_Names)} ='-1';
    end
end


%C matrix

C= repmat(unit_matrix, 1, numel(E_Names)+numel(V_Names)).';

%Stamping Vsource
for V =1:1:numel(V_Names)
    current_node_1 = str2double(V_Node_1(V));
    current_node_2 = str2double(V_Node_2(V));
    if current_node_1 ~= 0
        % add a line here to assign an element in C matrix
     C{V,current_node_1} ='+1';
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in C matrix
        C{V,current_node_2} ='-1';
    end
end
%Stamping VCVS
for E =1:1:numel(E_Names)
    current_node_1 = str2double(E_Node_1(E));
    current_node_2 = str2double(E_Node_2(E));
    Control_node_1 = str2double(E_Node_C1(E));
    Control_node_2 = str2double(E_Node_C2(E));
    current_name =E_Names{E};
    if current_node_1 ~= 0
        % add a line here to assign an element in B matrix
     C{E+(numel(V_Names)),current_node_1} = '+1';
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in B matrix
        C{E+(numel(V_Names)),current_node_2} ='-1';
    end
        if Control_node_1 ~= 0
        % add a line here to assign an element in B matrix
     C{E+(numel(V_Names)),Control_node_1} =['-1*' current_name];
        end
    if Control_node_2 ~= 0
        % add a line here to assign an element in B matrix
        C{E+(numel(V_Names)),Control_node_2} =['+1*' current_name];
    end
end



%Combining all in A matrix
a = [G; C(:,1:nodes_number)];
a = [a B];


A =str2sym(a);

%__Part 4__
%Symbolic
 symbolic_ans = A\Z;

%Numeric
%Fetch variables values

for R=1:1:numel(R_Names)
    eval([R_Names{R} ' = ' num2str(R_Values{R}) ';']);
end

for V=1:1:numel(V_Names)
    % add a line here to assign voltage sources values into double variables
      eval([V_Names{V} ' = ' num2str(V_Values{V}) ';']);
end

for I=1:1:numel(I_Names)
    % add a line here to assign voltage sources values into double variables
    eval([I_Names{I} ' = ' num2str(I_Values{I}) ';']);
end

for c=1:1:numel(C_Names)
     
    % add a line here to assign Capcitors values into double variables
  
    eval([C_Names{c} ' = ' num2str(C_Values{c}) ';']);
    
end
for g=1:1:numel(G_Names)
     
    % add a line here to assign VCCS values into double variables
  
    eval([G_Names{g} ' = ' num2str(G_Values{g}) ';']);
    
end

for e=1:1:numel(E_Names)
     
    % add a line here to assign VCVS values into double variables
  
    eval([E_Names{e} ' = ' num2str(E_Values{e}) ';']);
    
end

for l=1:1:numel(L_Names)
    
    % add a line here to assign Inductors values into double variables
    eval([L_Names{l} ' = ' num2str(L_Values{l}) ';']);
    
end

yplot=[];



% plotting in a decade way 

% m - start value (10^m)
% n - end value (10^n)
% s - step size into one decade
% (s = 10, step = 0.1*first term of every decade)
% (s = 1, step = first term of every decade, etc.)
% x - row decade vector
% initialization
m=log10(Freq_Start);
n=ceil(log10(Freq_Stop));
s=1/Freq_Step;
c = 0;
Freq = zeros(9/s, n-m);
% decades generation
for p = m:(n-1)
    c = c + 1;
    Freq(:, c) = ((1:s:10-s).*10^p)';
end
% decade vector generation
Freq = Freq(:)';
Freq = [Freq 10^n];


   for i=1:1:numel(Freq)
       % Looping over the frequency and increment it by the steps to have a vector we can plot 
     eval([ 'W' ' =  ' num2str(2*pi*Freq(i)) ';']);
%Substitute
% add a line here to substitute the symoblic solutions with the variables created in the previous step, and save it into num array
     numeric_ans=eval(subs(symbolic_ans));
     %adding Elements to the vector we want to plot 
     yplot= [yplot , double(numeric_ans(Plot_Node))];
   end

          
           
%Print
for i = 1:1:numel(symbolic_ans)
    fprintf('%s = %f\n', char(X(i)), double(abs(numeric_ans(i))));
end
% plotting Vout Vs Frequency  in log scale xaxis and db y axis 
%Adding A figure to plot
figure;
semilogx(Freq,db(abs(yplot)));
%adding x axis and y axis labels 
xlabel('Frequency magnitude');
ylabel('Vout');
title(netlist_directory);
% adding grid on the plot 
grid on;
% opening a new figure fo the phase plot 
figure ;
% adding grid on the plot 
grid on
% plotting Vout phase Vs Frequency  in log scale xaxis and degrees y axis 
semilogx(Freq,180*angle(yplot)/pi,'r:');
%adding x axis and y axis labels 
xlabel('Frequency');
ylabel('Vout phase');
% Adding Title for the Plots
title(netlist_directory);
end

