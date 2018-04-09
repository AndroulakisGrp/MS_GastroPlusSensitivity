%Script for Morris Method
%edited June 19 2017 by Meg

clear;clc;close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code Capabilities:
    %Sobol sampling of ASF and ACAT and PK model parameters
    %Incorporates correlations for underlying physiology for small intestine
    %Model Output: Cmax, tmax, AUC, Cp-time data, Fdp, Fa, F
    %Calculates Morris method sensitivity indices (mu, sigma, mu star)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Morris Method for 2 compartment PK model
%Added scramble function to Sobol sampling
%Changed interpolation method for tmax

MATLABfile='APAP_extremes_20pct_and_50pct.mat';


%% Set up for automation script
automation = 'C:\Users\megerle\Desktop\IPA_Group\Automation_Scripts\Parameter_Sensitivity\Morris\Final\GastroPlus_automation.exe';
excel = '\data_collection.xlsx';
filename0='\';

%Time Points for dynamic sensitivity analysis
TimePoints=(0:0.001:3);
Time=(0:0.1:6);

%Run simulation
a{1} = '1'; %Change to '0' if you don't want to run the simulation
%Copy plasma conc data (cmax, tmax, AUCs) and Cp-time data into Excel
a{2} = excel;
a{3} = excel;


%% Generate ACAT model physiology files for GastroPlus

%Import default ACAT model file
[~, ~, phystest_A] = xlsread('phys_test_A.xlsx','phystest');
phystest_A(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),phystest_A)) = {''};

%Nominal ACAT and PK compartment parameters
[values,names] = xlsread('input_parameters_v3.xlsx',3);
nominal_values=transpose(values);
    
%Computational Costs
num_of_factors = length(nominal_values); % number of input factors (sampled ACAT + PK model parameters)
num_of_output = 3; % number of output variables (Cmax, Tmax, AUC)
repetition_of_sampling=9;

%Specify limits for sampling
lower_bound=0.8*nominal_values; % specify lower bound
upper_bound=1.2*nominal_values; % specify upper bound
lower_bound_50=0.5*nominal_values; % specify lower bound
upper_bound_50=1.5*nominal_values; % specify upper bound

LB_Gastric_pH=nominal_values;
    LB_Gastric_pH(:,1)=lower_bound(:,1);
LB_Gastric_pH_50=nominal_values;
    LB_Gastric_pH_50(:,1)=lower_bound_50(:,1);
UB_Gastric_pH=nominal_values;
    UB_Gastric_pH(:,1)=upper_bound(:,1);
UB_Gastric_pH_50=nominal_values;
    UB_Gastric_pH_50(:,1)=upper_bound_50(:,1);
LB_BW=nominal_values;
    LB_BW(:,44)=lower_bound(:,44);
LB_BW_50=nominal_values;
    LB_BW_50(:,44)=lower_bound_50(:,44);
UB_BW=nominal_values;
    UB_BW(:,44)=upper_bound(:,44);
UB_BW_50=nominal_values;
    UB_BW_50(:,44)=upper_bound_50(:,44);

sample_points=[nominal_values;LB_Gastric_pH;UB_Gastric_pH;LB_BW;UB_BW;LB_Gastric_pH_50;UB_Gastric_pH_50;LB_BW_50;UB_BW_50];

%Initialize matrices
%Base
func_simu_base=zeros(repetition_of_sampling,num_of_output);
func_simu_base_Cp=zeros(repetition_of_sampling,length(Time));
time_base=zeros(repetition_of_sampling,length(Time));
func_simu_base_SigFig=zeros(repetition_of_sampling,num_of_output);

%Unscaled values in base and auxiliary matrices
base_points=sample_points;


%% Run GastroPlus for base matrix
    %Generate ACAT model files in base matrix
    %Update PK parameters in GastroPlus
    %Run GastroPlus for parameter sets in base matrix
    %Compile data for base matrix in MATLAB

tic

for i=1:repetition_of_sampling
    
%Update physiology files for base and auxiliary matrices
    phystest_A(3)=cellstr('Physiology: Physiology_A ');
    phystest_A(60)=cellstr(sprintf('Stomach pH =  %s ',num2str(base_points(i,1))));
    phystest_A(61)=cellstr(sprintf('Stomach Volume =  %s ',num2str(base_points(i,2))));
    phystest_A(67)=cellstr(sprintf('Stomach Comp Pore Radius = %s ',num2str(base_points(i,3))));
    phystest_A(68)=cellstr(sprintf('Stomach Comp Porosity/Pore Length = %s ',num2str(base_points(i,4))));
    phystest_A(69)=cellstr(sprintf('Stomach Transit Time = %s ',num2str(base_points(i,5))));
    phystest_A(103)=cellstr(sprintf('Duodenum pH = %s ',num2str(base_points(i,6))));
    phystest_A(109)=cellstr(sprintf('Duodenum Comp Bile = %s ',num2str(base_points(i,7))));
    phystest_A(110)=cellstr(sprintf('Duodenum Comp Pore Radius = %s ',num2str(base_points(i,8))));
    phystest_A(111)=cellstr(sprintf('Duodenum Comp Porosity/Pore Length = %s ',num2str(base_points(i,9))));
    phystest_A(146)=cellstr(sprintf('Jejunum 1 pH = %s ',num2str(base_points(i,10))));
    phystest_A(152)=cellstr(sprintf('Jejunum 1 Comp Bile = %s ',num2str(base_points(i,11))));
    phystest_A(153)=cellstr(sprintf('Jejunum 1 Comp Pore Radius = %s ',num2str(base_points(i,12))));
    phystest_A(154)=cellstr(sprintf('Jejunum 1 Comp Porosity/Pore Length = %s ',num2str(base_points(i,13))));
    phystest_A(195)=cellstr(sprintf('Jejunum 2 Comp Bile = %s ',num2str(base_points(i,14))));
    phystest_A(196)=cellstr(sprintf('Jejunum 2 Comp Pore Radius = %s ',num2str(base_points(i,15))));
    phystest_A(197)=cellstr(sprintf('Jejunum 2 Comp Porosity/Pore Length = %s ',num2str(base_points(i,16))));
    phystest_A(238)=cellstr(sprintf('Ileum 1 Comp Bile = %s ',num2str(base_points(i,17))));
    phystest_A(239)=cellstr(sprintf('Ileum 1 Comp Pore Radius = %s ',num2str(base_points(i,18))));
    phystest_A(240)=cellstr(sprintf('Ileum 1 Comp Porosity/Pore Length = %s ',num2str(base_points(i,19))));
    phystest_A(281)=cellstr(sprintf('Ileum 2 Comp Bile = %s ',num2str(base_points(i,20))));
    phystest_A(282)=cellstr(sprintf('Ileum 2 Comp Pore Radius = %s ',num2str(base_points(i,21))));
    phystest_A(283)=cellstr(sprintf('Ileum 2 Comp Porosity/Pore Length = %s ',num2str(base_points(i,22))));
    phystest_A(324)=cellstr(sprintf('Ileum 3 Comp Bile = %s ',num2str(base_points(i,23))));
    phystest_A(325)=cellstr(sprintf('Ileum 3 Comp Pore Radius = %s ',num2str(base_points(i,24))));
    phystest_A(326)=cellstr(sprintf('Ileum 3 Comp Porosity/Pore Length = %s ',num2str(base_points(i,25))));
    phystest_A(361)=cellstr(sprintf('Caecum pH = %s ',num2str(base_points(i,26))));
    phystest_A(363)=cellstr(sprintf('Caecum Length = %s ',num2str(base_points(i,27))));
    phystest_A(364)=cellstr(sprintf('Caecum Radius = %s ',num2str(base_points(i,28))));
    phystest_A(368)=cellstr(sprintf('Caecum Comp Pore Radius = %s ',num2str(base_points(i,29))));
    phystest_A(369)=cellstr(sprintf('Caecum Comp Porosity/Pore Length = %s ',num2str(base_points(i,30))));
    phystest_A(370)=cellstr(sprintf('Caecum Transit Time = %s ',num2str(base_points(i,31))));
    phystest_A(404)=cellstr(sprintf('Asc Colon pH = %s ',num2str(base_points(i,32))));
    phystest_A(406)=cellstr(sprintf('Asc Colon Length = %s ',num2str(base_points(i,33))));
    phystest_A(407)=cellstr(sprintf('Asc Colon Radius = %s ',num2str(base_points(i,34))));
    phystest_A(411)=cellstr(sprintf('Asc Colon Comp Pore Radius = %s ',num2str(base_points(i,35))));
    phystest_A(412)=cellstr(sprintf('Asc Colon Comp Porosity/Pore Length = %s ',num2str(base_points(i,36))));
    phystest_A(413)=cellstr(sprintf('Asc Colon Transit Time = %s ',num2str(base_points(i,37))));
    phystest_A(479)=cellstr(sprintf('Fasted State Volume Fraction =  %s ',num2str(base_points(i,38))));
    phystest_A(480)=cellstr(sprintf('Fasted State Volume Fraction Col =  %s ',num2str(base_points(i,39))));
    phystest_A(445)=cellstr(sprintf('Qh = %s ',num2str(base_points(i,40))));
    %Correlated Factors
    phystest_A(105)=cellstr(sprintf('Duodenum Length = %s ',num2str(base_points(i,41)*0.0462)));
    phystest_A(148)=cellstr(sprintf('Jejunum 1 Length = %s ',num2str((base_points(i,41)-base_points(i,41)*0.0462)/5)));
    phystest_A(191)=cellstr(sprintf('Jejunum 2 Length = %s ',num2str((base_points(i,41)-base_points(i,41)*0.0462)/5)));
    phystest_A(234)=cellstr(sprintf('Ileum 1 Length = %s ',num2str((base_points(i,41)-base_points(i,41)*0.0462)/5)));
    phystest_A(277)=cellstr(sprintf('Ileum 2 Length = %s ',num2str((base_points(i,41)-base_points(i,41)*0.0462)/5)));
    phystest_A(320)=cellstr(sprintf('Ileum 3 Length = %s ',num2str((base_points(i,41)-base_points(i,41)*0.0462)/5)));
    phystest_A(106)=cellstr(sprintf('Duodenum Radius = %s ',num2str(base_points(i,42)*1.6)));
    phystest_A(149)=cellstr(sprintf('Jejunum 1 Radius = %s ',num2str(base_points(i,42)*1.5)));
    phystest_A(192)=cellstr(sprintf('Jejunum 2 Radius = %s ',num2str(base_points(i,42)*1.34)));
    phystest_A(235)=cellstr(sprintf('Ileum 1 Radius = %s ',num2str(base_points(i,42)*1.18)));
    phystest_A(278)=cellstr(sprintf('Ileum 2 Radius = %s ',num2str(base_points(i,42)*1.01)));
    phystest_A(321)=cellstr(sprintf('Ileum 3 Radius = %s ',num2str(base_points(i,42)*0.85)));
    phystest_A(112)=cellstr(sprintf('Duodenum Transit Time = %s ',num2str(base_points(i,43)*0.0788)));
    phystest_A(155)=cellstr(sprintf('Jejunum 1 Transit Time = %s ',num2str(base_points(i,43)*0.2879)));
    phystest_A(198)=cellstr(sprintf('Jejunum 2 Transit Time = %s ',num2str(base_points(i,43)*0.2303)));
    phystest_A(241)=cellstr(sprintf('Ileum 1 Transit Time = %s ',num2str(base_points(i,43)*0.1788)));
    phystest_A(284)=cellstr(sprintf('Ileum 2 Transit Time = %s ',num2str(base_points(i,43)*0.1303)));
    phystest_A(327)=cellstr(sprintf('Ileum 3 Transit Time = %s ',num2str(base_points(i,43)*0.0939)));
    phystest_A(189)=cellstr(sprintf('Jejunum 2 pH = %s ',num2str(base_points(i,10)+0.2)));
    phystest_A(232)=cellstr(sprintf('Ileum 1 pH = %s ',num2str(base_points(i,10)+0.4)));
    phystest_A(275)=cellstr(sprintf('Ileum 2 pH = %s ',num2str(base_points(i,10)+0.7)));
    phystest_A(318)=cellstr(sprintf('Ileum 3 pH = %s ',num2str(base_points(i,10)+1.2)));
 
%Update ASF Model Coefficients, C1-C4
    phystest_A(9)=cellstr(sprintf('C1Alpha =  %s ',num2str(base_points(i,51))));
    phystest_A(10)=cellstr(sprintf('C2Alpha =  %s ',num2str(base_points(i,52))));
    phystest_A(11)=cellstr(sprintf('C3Alpha =  %s ',num2str(base_points(i,53))));
    phystest_A(12)=cellstr(sprintf('C4Alpha =  %s ',num2str(base_points(i,54))));
    
%Update ACAT model parameters and generate physiology files for Base Matrix
    filename_A='Physiology_A.txt';
    writetable(cell2table(phystest_A),filename_A,'WriteVariableNames',false,'Delimiter','\t');
    a{4}=strcat(filename0,filename_A);

%Update PK compartment parameters in GastroPlus for Base Matrix
        %Leave anything you don't want to change as nah
        nah = '54875';
        %Last entered values used for parameters set to 'nah'
        
    Body_weight = num2str(base_points(i,44)); %kg. Do not set this to 0, G+ will have an error and set weight to 70
    Blood_Plasma_Conc_Ratio = num2str(base_points(i,45));
    Exp_Plasma_Fup = num2str(base_points(i,46)); % %
    CL = num2str(base_points(i,47)); %L/h
    Vc = num2str(base_points(i,48)); %L/kg
    K12 = num2str(base_points(i,49)); %1/h
    K21 = num2str(base_points(i,50)); %1/h
    K13 = nah; %1/h
    K31 = nah; %1/h
    Renal_clearance = num2str(base_points(i,55)); %L/h/kg
    FPE_intestinal = nah; % %
    FPE_liver = nah; % %
    a{5} = [Body_weight, '+',  Blood_Plasma_Conc_Ratio, '+', Exp_Plasma_Fup, '+', CL, '+', Vc, '+', K12, '+', K21, '+', K13, '+', K31, '+', Renal_clearance, '+', FPE_intestinal, '+', FPE_liver];
%Convert cells to string

inputs = [automation ' '];
for m = 1:length(a)
    inputs = strcat(inputs, '~', a{m});
    inputs = strrep(inputs, '~', ' ');
end
   
%Run GastroPlus
[status, result] = system(inputs);

%%%%%%%%%%%%%%%%%%%%Data collection%%%%%%%%%%%%%%%%%%%%%%%%%
%Don't try to collect data on error
k = strfind(result, 'Error');
if isempty(k) == 1 

newline = sprintf('\n');

if strcmp(a{2}, excel) == 1 %2. plasma conc stuff
    newlines = strfind(result, newline);

    %Find drug
    drug_exist = strfind(result, 'Drug: '); %index is where Tmax is
    if isempty(drug_exist) == 0 
        %index of end of line
        drug_end = find(newlines>drug_exist(1),1);
        %add 6 for length of the string 'Drug: '
        drug = result(drug_exist + 6 : newlines(drug_end));
    end
    
    %Find cmax
    cmax_exist = strfind(result, 'Cmax: '); %index is where Cmax is
    if isempty(cmax_exist) == 0
        %use the location of newlines to copy the cmax. (the index closest and over of the cmax_exist index)
        %index of end of line
        cmax_end = find(newlines>cmax_exist(1),1);
        %add 6 for length of the string 'Cmax '
        cmax = str2num(result(cmax_exist + 6 : newlines(cmax_end)));
    end
    
    %Find tmax
    tmax_exist = strfind(result, 'Tmax: '); %index is where Tmax is
    if isempty(tmax_exist) == 0 
        %index of end of line
        tmax_end = find(newlines>tmax_exist(1),1);
        %add 6 for length of the string 'Tmax: '
        tmax = str2num(result(tmax_exist + 6 : newlines(tmax_end)));
    end
    
    %Find AUC 0-inf
    AUC0i_exist = strfind(result, 'AUC (0-inf): '); %index is where AUC 0-inf is
    if isempty(AUC0i_exist) == 0 
        %index of end of line
        AUC0i_end = find(newlines>AUC0i_exist(1),1);
        %add 13 for length of the string 'AUC (0-inf): '
        AUC_0_inf = str2num(result(AUC0i_exist + 13 : newlines(AUC0i_end)));
    end   
    
    %Find AUC 0-t
    AUC0t_exist = strfind(result, 'AUC (0-t): '); %index is where AUC 0-t is
    if isempty(AUC0t_exist) == 0  
        %index of end of line
        AUC0t_end = find(newlines>AUC0t_exist(1),1);
        %add 11 for length of the string 'AUC (0-t): '
        AUC_0_t = str2num(result(AUC0t_exist + 11 : newlines(AUC0t_end)));
    end   
 
    %Find Fa %
    Fa_exist = strfind(result, 'Fa %: '); %index is where Fa % is
    if isempty(Fa_exist) == 0 
        %index of end of line
        Fa_end = find(newlines>Fa_exist(1),1);
        %add 6 for length of the string 'Fa %: '
        Fa = str2num(result(Fa_exist + 6 : newlines(Fa_end)));
    end   
    
    %Find FDp %
    FDp_exist = strfind(result, 'FDp %: '); %index is where FDp % is
    if isempty(FDp_exist) == 0 
        %index of end of line
        FDp_end = find(newlines>FDp_exist(1),1);
        %add 7 for length of the string 'FDp %: '
        FDp = str2num(result(FDp_exist + 7 : newlines(FDp_end)));
    end   

    %Find F %
    F_exist = strfind(result, 'F %: '); %index is where F % is
    if isempty(F_exist) == 0 
        %index of end of line
        F_end = find(newlines>F_exist(1),1);
        %add 5 for length of the string 'FDp %: '
        F = str2num(result(F_exist + 5 : newlines(F_end)));
    end

end

 if strcmp(a{3}, excel) == 1 %3. plasma conc profile
     pc_exist1 = strfind(result, 'pc start'); %Find 'pc start'
     pc_exist2 = strfind(result, 'pc end'); %Find 'pc end'
     
     %Delete everything before and after, including 'pc start', 'pc end'
     before = result(1:pc_exist1 + 7);
     after = result(pc_exist2:end);
     
     %Remove stuff to set up for str2num
     result2 = strrep(result, before, '');
     result3 = strrep(result2, after, '');
     result4 = strrep(result3, newline, ' ');
    
     %str2num and organize
     result5 = str2num(result4);
     
     %splitting the plasma conc and time
        len = length(result5);
        time_i = 1:2:len;
        conc_i = 2:2:len;
        
        %organizing data
        for m = 1:length(time_i)
            time_A(m) = result5(time_i(m));
        end

        for m = 1:length(conc_i)
            conc_A(m) = result5(conc_i(m));
        end
        
 end
end

%Output: Cmax, tmax, AUC (0-t)
func_simu_base(i,:)=[cmax tmax AUC_0_t];
% %Output: Cp-time
Time_A=time_A(:,find(unique(conc_A)));
Conc_A=conc_A(:,find(unique(conc_A)));
dataA=interp1(Time_A(:,1:end),Conc_A(:,1:end),Time,'spline');
CpTime_data_A=transpose([Time;dataA]);
time_base(i,:)=CpTime_data_A(:,1);
func_simu_base_Cp(i,:)=CpTime_data_A(:,2);

%Finds tmax from interpolation of Cp-time data
dataA_v2=interp1(Time_A(:,1:end),Conc_A(:,1:end),TimePoints,'spline');
CpTime_data_A_v2=transpose([TimePoints;dataA_v2]);
[findCmax,findTime]=max(CpTime_data_A_v2(:,2));
tmax2=CpTime_data_A_v2(findTime,1);
func_simu_base_SigFig(i,:)=[cmax tmax2 AUC_0_t];

display(sprintf('GastroPlus run for base Sample %s.',num2str(i)))
end
toc

save(MATLABfile)

%% Calculation of Elementary Effects

EE=zeros(8,num_of_output);

for i=[2 4 6 8]
    for j=1:num_of_output
    EE(i-1,j)=(func_simu_base_SigFig(i,j)-func_simu_base_SigFig(1,j))/-0.5;
    end
end

for i=[3 5 7 9]
    for j=1:num_of_output
    EE(i-1,j)=(func_simu_base_SigFig(i,j)-func_simu_base_SigFig(1,j))/0.5;
    end
end

%% Calculation of PCT Difference

PctDiff=zeros(8,num_of_output);

for i=[2:9]
    for j=1:num_of_output
    PctDiff(i-1,j)=abs((func_simu_base_SigFig(i,j)-func_simu_base_SigFig(1,j))/func_simu_base_SigFig(1,j)*100);
    end
end


%% Plot Plasma concentration profiles

time=time_base;
Cp=func_simu_base_Cp;

labels={'Baseline Prediction','-20% Gastric pH','+20% Gastric pH','-20% Body Weight','+20% Body Weight'};

figure
% subplot(1,2,1)
plot(time(1,:),Cp(1,:),'LineWidth',3,'Color','k')
hold on
plot(time(2,:),Cp(2,:),'--g','LineWidth',2)
plot(time(3,:),Cp(3,:),':m','LineWidth',2)
plot(time(4,:),Cp(4,:),'LineWidth',2,'Color','r')
plot(time(5,:),Cp(5,:),'LineWidth',2,'Color','b')
ax=gca;
ax.YLabel.String='Plasma Concentration (mg/mL)';
ax.YLabel.FontSize=16;
ax.XLabel.String='Time (hr)';
ax.XLabel.FontSize=16;
ax.YLabel.FontWeight='bold';
ax.XLabel.FontWeight='bold';
ax.XAxis.FontSize=16;
ax.YAxis.FontSize=16;
ax.Box = 'on'
ax.XLim=[0 6];
ax.YLim=[0 15];
ax.XTick=0:1:6;
legend(labels,'Location','northeast','FontSize',14);
% title('(A) Plasma Concentration at Sampling Bounds: +/- 20%','FontSize',16);
hold off

labels={'Baseline Prediction','-50% Gastric pH','+50% Gastric pH','-50% Body Weight','+50% Body Weight'};

figure
% subplot(1,2,2)
plot(time(1,:),Cp(1,:),'LineWidth',3,'Color','k')
hold on
plot(time(6,:),Cp(6,:),'--g','LineWidth',2)
plot(time(7,:),Cp(7,:),':m','LineWidth',2)
plot(time(8,:),Cp(8,:),'LineWidth',2,'Color','r')
plot(time(9,:),Cp(9,:),'LineWidth',2,'Color','b')
ax=gca;
ax.YLabel.String='Plasma Concentration (mg/mL)';
ax.YLabel.FontSize=16;
ax.XLabel.String='Time (hr)';
ax.XLabel.FontSize=16;
ax.YLabel.FontWeight='bold';
ax.XLabel.FontWeight='bold';
ax.XAxis.FontSize=16;
ax.YAxis.FontSize=16;
ax.Box = 'on'
ax.XLim=[0 6];
ax.YLim=[0 15];
ax.XTick=0:1:6;
legend(labels,'Location','northeast','FontSize',14);
% title('(B) Plasma Concentration at Sampling Bounds: +/- 50%','FontSize',16);
hold off
