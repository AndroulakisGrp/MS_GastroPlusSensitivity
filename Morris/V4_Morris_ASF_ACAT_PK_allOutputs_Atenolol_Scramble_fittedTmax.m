%Script for Morris Method
%edited August 8 2017 by Meg

clear;clc;close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code Capabilities:
    %Sobol sampling of ASF and ACAT and PK model parameters
    %Incorporates correlations for underlying physiology for small intestine
    %Model Output: Cmax, tmax, AUC, Cp-time data, Fdp, Fa, F
    %Calculates Morris method sensitivity indices (mu, sigma, mu star)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%New to version:
%Tmax determined by interpolation


%% Set up for automation script
automation = 'C:\Users\ROHIT\Desktop\Final\GastroPlus_automation_v2.exe';
excel = '\data_collection.xlsx';
filename0='\';

%Time Points for dynamic sensitivity analysis
TimePoints=(2:0.001:4);
Time=(0:0.1:24);

%Identifies files to be uploaded into GastroPlus
a{6} = '0'; %No dissolution file uploaded
a{8} = '0'; %Drug table not uploaded
a{9} = '0'; %pKa table not uploaded

%Run simulation
a{1} = '1'; %Change to '0' if you don't want to run the simulation
%Copy plasma conc data (cmax, tmax, AUCs) and Cp-time data into Excel
a{2} = excel; %Copies PK summary data into Excel
a{3} = excel; %Copies Cp-time data into Excel
a{10} = '0'; %Copies regional absorption data into Excel


%% Generate ACAT model physiology files for GastroPlus

%Import default ACAT model file
[~, ~, phystest_A] = xlsread('phys_test_A.xlsx','phystest');
phystest_A(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),phystest_A)) = {''};
[~, ~, phystest_EE] = xlsread('phys_test_EE.xlsx','phystest');
phystest_EE(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),phystest_EE)) = {''};

%Nominal ACAT and PK compartment parameters
[values,names] = xlsread('input_parameters_v3.xlsx',8);
nominal_values=transpose(values);
    
%Computational Costs
num_of_factors = length(nominal_values); % number of input factors (sampled ACAT + PK model parameters)
num_of_output = 3; % number of output variables (Cmax, Tmax, AUC, Fa, FDp, F)
repetition_of_sampling = 20; % number of N, should be set to 8 or larger
Computational_costs=repetition_of_sampling*(num_of_factors+1);

%Specify limits for sampling
lower_bound=0.8*nominal_values; % specify lower bound
upper_bound=1.2*nominal_values; % specify upper bound

%Initialize matrices
%Base and Auxiliary
    func_simu_base=zeros(repetition_of_sampling,num_of_output);
    func_simu_base_Cp=zeros(repetition_of_sampling,length(Time));
    time_base=zeros(repetition_of_sampling,length(Time));
    func_simu_base_SigFig=zeros(repetition_of_sampling,num_of_output);
%EE
    func_simu_EE=zeros(repetition_of_sampling,num_of_factors,num_of_output);
    func_simu_EE_Cp=zeros(repetition_of_sampling,num_of_factors,length(Time));
    output_simu_EE=zeros(repetition_of_sampling,num_of_output);
    output_simu_EE_Cp=zeros(repetition_of_sampling,length(Time));
    all_time_EE=zeros(repetition_of_sampling,num_of_factors,length(Time));
    alloutput=zeros(repetition_of_sampling,num_of_output,num_of_factors);
    alloutput_Cp=zeros(repetition_of_sampling,length(Time),num_of_factors);
    func_simu_EE_SigFig=zeros(repetition_of_sampling,num_of_factors,num_of_output);
    output_simu_EE_SigFig=zeros(repetition_of_sampling,num_of_output);
    alloutput_SigFig=zeros(repetition_of_sampling,num_of_output,num_of_factors);

%Sobol sampling
temp_sample_points_p=sobolset(num_of_factors);
temp_sample_points_p = scramble(temp_sample_points_p,'MatousekAffineOwen');
temp_sample_points=net(temp_sample_points_p,repetition_of_sampling*2+1);
sample_points=zeros(repetition_of_sampling*2,num_of_factors);

for i = 1:2*repetition_of_sampling
    sample_points(i,:) = lower_bound + (upper_bound - lower_bound).*temp_sample_points(i+1,:);
end

%Unscaled values in base and auxiliary matrices
base_points=sample_points(1:repetition_of_sampling,:);
auxiliary_points=sample_points(repetition_of_sampling+1:2*repetition_of_sampling,:);

%Scale values from 0 to 1
%Fraction = (Value-Lower Bound)/(Upper Bound-Lower Bound) 
base_points_frac=temp_sample_points(2:repetition_of_sampling+1,:);
auxiliary_points_frac=temp_sample_points(repetition_of_sampling+2:2*repetition_of_sampling+1,:);


%% Run GastroPlus for base matrix
    %Generate ACAT model files in base matrix
    %Update PK parameters in GastroPlus
    %Run GastroPlus for parameter sets in base matrix
    %Compile data for base matrix in MATLAB

MATLABfile='Morris_Atenolol_r20_fittedTmax.mat';

time_A=[];
conc_A=[];
Time_A=[];
Conc_A=[];

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
    Renal_clearance = nah; %L/h/kg
    FPE_intestinal = nah; % %
    FPE_liver = nah; % %
    a{5} = [Body_weight, '+',  Blood_Plasma_Conc_Ratio, '+', Exp_Plasma_Fup, '+', CL, '+', Vc, '+', K12, '+', K21, '+', K13, '+', K31, '+', Renal_clearance, '+', FPE_intestinal, '+', FPE_liver];

%Update EHC Model Parameters in GastroPlus
    check_readsorb = '0'; % '1' to allow re-adsorbtion, '0' to not allow it
    %Leave anything you don't want to change as nah
    Bilary_Cl = nah; %Biliary Clearance Fraction
    Gall_Empty = nah; %Gallbladder Emptying Time (min)
    Gall_Div = nah; %Gallbladder Diversion Fraction
    a{7} = [check_readsorb, '+',  Bilary_Cl, '+', Gall_Empty, '+', Gall_Div];    
    
%Convert cells to string
inputs = [automation ' '];
for n = 1:length(a)
    inputs = strcat(inputs, '~', a{n});
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
        %index of end of line)
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
     newlines = strfind(result, newline);
      
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
 
 if strcmp(a{10}, excel) == 1 %10. regional absorption
     newlines = strfind(result, newline);
      
     ra_exist1 = strfind(result, 'ra start'); %Find 'ra start'
     ra_exist2 = strfind(result, 'ra end'); %Find 'ra end'
     
     %Delete everything before and after, including 'ra start', 'ra end'
     before_ra = result(1:ra_exist1 + 7);
     after_ra = result(ra_exist2:end);
     result2_ra = strrep(result, before_ra, '');
     result3_ra = strrep(result2_ra, after_ra, '');
     result4_ra = strrep(result3_ra, newline, ' ');
     
    %Find Stomach 
    sto_exist = strfind(result, 'Stomach'); %index is where stomach is
    if isempty(sto_exist) == 0 
        %index of end of line (+2)
        sto_end = find(newlines>sto_exist(1),1);
        %add 7 for length of the string 'Stomach', subtract 2 for '% '
        Stomach = str2num(result(sto_exist + 7 : newlines(sto_end) - 2));
    end
      
    %Find Duodenum
    duo_exist = strfind(result, 'Duodenum'); %index is where Duodenum is
    if isempty(duo_exist) == 0 
        %index of end of line (+2)
        duo_end = find(newlines>duo_exist(1),1);
        %add 8 for length of the string 'Duodenum'
        Duodenum = str2num(result(duo_exist + 8 : newlines(duo_end) - 2));
    end
    
    %Find Jejunum 1
    Je1_exist = strfind(result, 'Jejunum 1'); %index is where Jejunum 1 is
    if isempty(Je1_exist) == 0 
        %index of end of line (+2)
        Je1_end = find(newlines>Je1_exist(1),1);
        %add 9 for length of the string 'Jejunum 1'
        Jejunum_1 = str2num(result(Je1_exist + 9 : newlines(Je1_end) - 2));
    end
    
    %Find Jejunum 2
    Je2_exist = strfind(result, 'Jejunum 2'); %index is where Jejunum 2 is
    if isempty(Je2_exist) == 0 
        %index of end of line (+2)
        Je2_end = find(newlines>Je2_exist(1),1);
        %add 9 for length of the string 'Jejunum 2'
        Jejunum_2 = str2num(result(Je2_exist + 9 : newlines(Je2_end) - 2));
    end
    
    %Find Ileum 1
    Il1_exist = strfind(result, 'Ileum 1'); %index is where Ileum 1 is
    if isempty(Il1_exist) == 0 
        %index of end of line (+2)
        Il1_end = find(newlines>Il1_exist(1),1);
        %add 7 for length of the string 'Ileum 1'
        Ileum_1 = str2num(result(Il1_exist + 7 : newlines(Il1_end) - 2));
    end
    
    %Find Ileum 2
    Il2_exist = strfind(result, 'Ileum 2'); %index is where Ileum 2 is
    if isempty(Il2_exist) == 0 
        %index of end of line (+2)
        Il2_end = find(newlines>Il2_exist(1),1);
        %add 7 for length of the string 'Ileum 2'
        Ileum_2 = str2num(result(Il2_exist + 7 : newlines(Il2_end) - 2));
    end
    
    %Find Ileum 3
    Il3_exist = strfind(result, 'Ileum 3'); %index is where Ileum 3 is
    if isempty(Il3_exist) == 0 
        %index of end of line (+2)
        Il3_end = find(newlines>Il3_exist(1),1);
        %add 7 for length of the string 'Ileum 3'
        Ileum_3 = str2num(result(Il3_exist + 7 : newlines(Il3_end) - 2));
    end
 
    %Find Caecum
    Cae_exist = strfind(result, 'Caecum'); %index is where Caecum is
    if isempty(Cae_exist) == 0 
        %index of end of line (+2)
        Cae_end = find(newlines>Cae_exist(1),1);
        %add 6 for length of the string 'Caecum'
        Caecum = str2num(result(Cae_exist + 6 : newlines(Cae_end) - 2));
    end
    
    %Find Asc Colon
    Asc_exist = strfind(result, 'Asc Colon'); %index is where Asc Colon is
    if isempty(Asc_exist) == 0 
        %index of end of line (+2)
        Asc_end = find(newlines>Asc_exist(1),1);
        %add 9 for length of the string 'Asc Colon'
        Asc_Colon = str2num(result(Asc_exist + 9 : newlines(Asc_end) - 2));
    end

    %Find AmtAbs
    Amt_exist = strfind(result, 'AmtAbs'); %index is where AmtAbs is
    if isempty(Amt_exist) == 0 
        %index of end of line (+2)
        Amt_end = find(newlines>Amt_exist(1),1);
        %add 6 for length of the string 'AmtAbs'
        AmtAbs = str2num(result(Amt_exist + 6 : newlines(Amt_end) - 2));
    end
 %end of compartments   
 end
%end of data collection
end

%Output: Cmax, tmax, AUC (0-t)

func_simu_base(i,:)=[cmax tmax AUC_0_t];
%Output: Cp-time
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

time_A=[];
conc_A=[];
Time_A=[];
Conc_A=[];
end
toc

save(MATLABfile);


%% Run GastroPlus to get all numbers for EE
    %Generate ACAT model files for sensitivity index calculations

    %Update PK parameters in GastroPlus
    %Run GastroPlus for parameter sets in sensitivity index calculations
    %Compile data in MATLAB

    time_EE=[];
    conc_EE=[];
    Time_EE=[];
    Conc_EE=[];
    
tic
for i=45%33:num_of_factors    
    
    temp=base_points;  
    
    temp(:,i)=auxiliary_points(:,i);
    temp_frac = base_points_frac;
    
    temp_frac(:,i) = auxiliary_points_frac(:,i);

    for j=[5 9]%1:repetition_of_sampling

    phystest_EE(3)=cellstr('Physiology: Physiology_EE ');
    phystest_EE(60)=cellstr(sprintf('Stomach pH =  %s ',num2str(temp(j,1))));
    phystest_EE(61)=cellstr(sprintf('Stomach Volume =  %s ',num2str(temp(j,2))));    
    phystest_EE(67)=cellstr(sprintf('Stomach Comp Pore Radius = %s ',num2str(temp(j,3))));
    phystest_EE(68)=cellstr(sprintf('Stomach Comp Porosity/Pore Length = %s ',num2str(temp(j,4))));
    phystest_EE(69)=cellstr(sprintf('Stomach Transit Time =  %s ',num2str(temp(j,5))));
    phystest_EE(103)=cellstr(sprintf('Duodenum pH = %s ',num2str(temp(j,6))));   
    phystest_EE(109)=cellstr(sprintf('Duodenum Comp Bile = %s ',num2str(temp(j,7))));
    phystest_EE(110)=cellstr(sprintf('Duodenum Comp Pore Radius = %s ',num2str(temp(j,8))));    
    phystest_EE(111)=cellstr(sprintf('Duodenum Comp Porosity/Pore Length = %s ',num2str(temp(j,9))));
    phystest_EE(146)=cellstr(sprintf('Jejunum 1 pH = %s ',num2str(temp(j,10))));    
    phystest_EE(152)=cellstr(sprintf('Jejunum 1 Comp Bile = %s ',num2str(temp(j,11))));
    phystest_EE(153)=cellstr(sprintf('Jejunum 1 Comp Pore Radius = %s ',num2str(temp(j,12))));    
    phystest_EE(154)=cellstr(sprintf('Jejunum 1 Comp Porosity/Pore Length = %s ',num2str(temp(j,13))));
    phystest_EE(195)=cellstr(sprintf('Jejunum 2 Comp Bile = %s ',num2str(temp(j,14))));    
    phystest_EE(196)=cellstr(sprintf('Jejunum 2 Comp Pore Radius = %s ',num2str(temp(j,15))));
    phystest_EE(197)=cellstr(sprintf('Jejunum 2 Comp Porosity/Pore Length = %s ',num2str(temp(j,16))));
    phystest_EE(238)=cellstr(sprintf('Ileum 1 Comp Bile = %s ',num2str(temp(j,17))));
    phystest_EE(239)=cellstr(sprintf('Ileum 1 Comp Pore Radius = %s ',num2str(temp(j,18))));
    phystest_EE(240)=cellstr(sprintf('Ileum 1 Comp Porosity/Pore Length = %s ',num2str(temp(j,19))));
    phystest_EE(281)=cellstr(sprintf('Ileum 2 Comp Bile = %s ',num2str(temp(j,20))));
    phystest_EE(282)=cellstr(sprintf('Ileum 2 Comp Pore Radius = %s ',num2str(temp(j,21))));
    phystest_EE(283)=cellstr(sprintf('Ileum 2 Comp Porosity/Pore Length = %s ',num2str(temp(j,22))));
    phystest_EE(324)=cellstr(sprintf('Ileum 3 Comp Bile = %s ',num2str(temp(j,23))));
    phystest_EE(325)=cellstr(sprintf('Ileum 3 Comp Pore Radius = %s ',num2str(temp(j,24))));
    phystest_EE(326)=cellstr(sprintf('Ileum 3 Comp Porosity/Pore Length = %s ',num2str(temp(j,25))));
    phystest_EE(361)=cellstr(sprintf('Caecum pH = %s ',num2str(temp(j,26))));
    phystest_EE(363)=cellstr(sprintf('Caecum Length = %s ',num2str(temp(j,27))));
    phystest_EE(364)=cellstr(sprintf('Caecum Radius = %s ',num2str(temp(j,28))));
    phystest_EE(368)=cellstr(sprintf('Caecum Comp Pore Radius = %s ',num2str(temp(j,29))));
    phystest_EE(369)=cellstr(sprintf('Caecum Comp Porosity/Pore Length = %s ',num2str(temp(j,30))));
    phystest_EE(370)=cellstr(sprintf('Caecum Transit Time = %s ',num2str(temp(j,31))));
    phystest_EE(404)=cellstr(sprintf('Asc Colon pH = %s ',num2str(temp(j,32))));
    phystest_EE(406)=cellstr(sprintf('Asc Colon Length = %s ',num2str(temp(j,33))));
    phystest_EE(407)=cellstr(sprintf('Asc Colon Radius = %s ',num2str(temp(j,34))));
    phystest_EE(411)=cellstr(sprintf('Asc Colon Comp Pore Radius = %s ',num2str(temp(j,35))));
    phystest_EE(412)=cellstr(sprintf('Asc Colon Comp Porosity/Pore Length = %s ',num2str(temp(j,36))));
    phystest_EE(413)=cellstr(sprintf('Asc Colon Transit Time = %s ',num2str(temp(j,37))));
    phystest_EE(479)=cellstr(sprintf('Fasted State Volume Fraction =  %s ',num2str(temp(j,38))));
    phystest_EE(480)=cellstr(sprintf('Fasted State Volume Fraction Col =  %s ',num2str(temp(j,39))));
    phystest_EE(445)=cellstr(sprintf('Qh = %s ',num2str(temp(j,40))));
    
    %Correlated Factors
    phystest_EE(105)=cellstr(sprintf('Duodenum Length = %s ',num2str(temp(j,41)*0.0462)));
    phystest_EE(148)=cellstr(sprintf('Jejunum 1 Length = %s ',num2str((temp(j,41)-temp(j,41)*0.0462)/5)));
    phystest_EE(191)=cellstr(sprintf('Jejunum 2 Length = %s ',num2str((temp(j,41)-temp(j,41)*0.0462)/5)));
    phystest_EE(234)=cellstr(sprintf('Ileum 1 Length = %s ',num2str((temp(j,41)-temp(j,41)*0.0462)/5)));
    phystest_EE(277)=cellstr(sprintf('Ileum 2 Length = %s ',num2str((temp(j,41)-temp(j,41)*0.0462)/5)));
    phystest_EE(320)=cellstr(sprintf('Ileum 3 Length = %s ',num2str((temp(j,41)-temp(j,41)*0.0462)/5)));
    phystest_EE(106)=cellstr(sprintf('Duodenum Radius = %s ',num2str(temp(j,42)*1.6)));
    phystest_EE(149)=cellstr(sprintf('Jejunum 1 Radius = %s ',num2str(temp(j,42)*1.5)));
    phystest_EE(192)=cellstr(sprintf('Jejunum 2 Radius = %s ',num2str(temp(j,42)*1.34)));
    phystest_EE(235)=cellstr(sprintf('Ileum 1 Radius = %s ',num2str(temp(j,42)*1.18)));
    phystest_EE(278)=cellstr(sprintf('Ileum 2 Radius = %s ',num2str(temp(j,42)*1.01)));
    phystest_EE(321)=cellstr(sprintf('Ileum 3 Radius = %s ',num2str(temp(j,42)*0.85)));
    phystest_EE(112)=cellstr(sprintf('Duodenum Transit Time = %s ',num2str(temp(j,43)*0.0788)));
    phystest_EE(155)=cellstr(sprintf('Jejunum 1 Transit Time = %s ',num2str(temp(j,43)*0.2879)));
    phystest_EE(198)=cellstr(sprintf('Jejunum 2 Transit Time = %s ',num2str(temp(j,43)*0.2303)));
    phystest_EE(241)=cellstr(sprintf('Ileum 1 Transit Time = %s ',num2str(temp(j,43)*0.1788)));
    phystest_EE(284)=cellstr(sprintf('Ileum 2 Transit Time = %s ',num2str(temp(j,43)*0.1303)));
    phystest_EE(327)=cellstr(sprintf('Ileum 3 Transit Time = %s ',num2str(temp(j,43)*0.0939)));
    phystest_EE(189)=cellstr(sprintf('Jejunum 2 pH = %s ',num2str(temp(j,10)+0.2)));
    phystest_EE(232)=cellstr(sprintf('Ileum 1 pH = %s ',num2str(temp(j,10)+0.4)));
    phystest_EE(275)=cellstr(sprintf('Ileum 2 pH = %s ',num2str(temp(j,10)+0.7)));
    phystest_EE(318)=cellstr(sprintf('Ileum 3 pH = %s ',num2str(temp(j,10)+1.2)));

 %Update ASF Model Coefficients, C1-C4
    phystest_EE(9)=cellstr(sprintf('C1Alpha =  %s ',num2str(temp(j,51))));
    phystest_EE(10)=cellstr(sprintf('C2Alpha =  %s ',num2str(temp(j,52))));
    phystest_EE(11)=cellstr(sprintf('C3Alpha =  %s ',num2str(temp(j,53))));
    phystest_EE(12)=cellstr(sprintf('C4Alpha =  %s ',num2str(temp(j,54))));
    
%Save ACAT model files for Base and Auxiliary Matrix
    filename_EE='Physiology_EE.txt';
    %Writes updated physiology to text files
    writetable(cell2table(phystest_EE),filename_EE,'WriteVariableNames',false,'Delimiter','\t');
    a{4}=strcat(filename0,filename_EE);

 %Update PK compartment parameters in GastroPlus for resampling matrices
        %Leave anything you don't want to change as nah
        nah = '54875';
        %Last entered values used for parameters set to 'nah'
    Body_weight = num2str(temp(j,44)); %kg. Do not set this to 0, G+ will have an error and set weight to 70
    Blood_Plasma_Conc_Ratio = num2str(temp(j,45));
    Exp_Plasma_Fup = num2str(temp(j,46)); % %
    CL = num2str(temp(j,47)); %L/h
    Vc = num2str(temp(j,48)); %L/kg
    K12 = num2str(temp(j,49)); %1/
    K21 = num2str(temp(j,50)); %1/h
    K13 = nah; %1/h
    K31 = nah; %1/h
    Renal_clearance = nah; %L/h/kg
    FPE_intestinal = nah; % %
    FPE_liver = nah; % %
    a{5} = [Body_weight, '+',  Blood_Plasma_Conc_Ratio, '+', Exp_Plasma_Fup, '+', CL, '+', Vc, '+', K12, '+', K21, '+', K13, '+', K31, '+', Renal_clearance, '+', FPE_intestinal, '+', FPE_liver];

%Update EHC Model Parameters in GastroPlus
    check_readsorb = '0'; % '1' to allow re-adsorbtion, '0' to not allow it
    %Leave anything you don't want to change as nah
    Bilary_Cl = nah; %Biliary Clearance Fraction
    Gall_Empty = nah; %Gallbladder Emptying Time (min)
    Gall_Div = nah; %Gallbladder Diversion Fraction
    a{7} = [check_readsorb, '+',  Bilary_Cl, '+', Gall_Empty, '+', Gall_Div];    
    
%Convert cells to string
inputs = [automation ' '];
for n = 1:length(a)
    inputs = strcat(inputs, '~', a{n});
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
        %index of end of line)
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
     newlines = strfind(result, newline);
      
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
            time_EE(m) = result5(time_i(m));
        end

        for m = 1:length(conc_i)
            conc_EE(m) = result5(conc_i(m));
        end
        
 end
 
 if strcmp(a{10}, excel) == 1 %10. regional absorption
     newlines = strfind(result, newline);
      
     ra_exist1 = strfind(result, 'ra start'); %Find 'ra start'
     ra_exist2 = strfind(result, 'ra end'); %Find 'ra end'
     
     %Delete everything before and after, including 'ra start', 'ra end'
     before_ra = result(1:ra_exist1 + 7);
     after_ra = result(ra_exist2:end);
     result2_ra = strrep(result, before_ra, '');
     result3_ra = strrep(result2_ra, after_ra, '');
     result4_ra = strrep(result3_ra, newline, ' ');
     
    %Find Stomach 
    sto_exist = strfind(result, 'Stomach'); %index is where stomach is
    if isempty(sto_exist) == 0 
        %index of end of line (+2)
        sto_end = find(newlines>sto_exist(1),1);
        %add 7 for length of the string 'Stomach', subtract 2 for '% '
        Stomach = str2num(result(sto_exist + 7 : newlines(sto_end) - 2));
    end
      
    %Find Duodenum
    duo_exist = strfind(result, 'Duodenum'); %index is where Duodenum is
    if isempty(duo_exist) == 0 
        %index of end of line (+2)
        duo_end = find(newlines>duo_exist(1),1);
        %add 8 for length of the string 'Duodenum'
        Duodenum = str2num(result(duo_exist + 8 : newlines(duo_end) - 2));
    end
    
    %Find Jejunum 1
    Je1_exist = strfind(result, 'Jejunum 1'); %index is where Jejunum 1 is
    if isempty(Je1_exist) == 0 
        %index of end of line (+2)
        Je1_end = find(newlines>Je1_exist(1),1);
        %add 9 for length of the string 'Jejunum 1'
        Jejunum_1 = str2num(result(Je1_exist + 9 : newlines(Je1_end) - 2));
    end
    
    %Find Jejunum 2
    Je2_exist = strfind(result, 'Jejunum 2'); %index is where Jejunum 2 is
    if isempty(Je2_exist) == 0 
        %index of end of line (+2)
        Je2_end = find(newlines>Je2_exist(1),1);
        %add 9 for length of the string 'Jejunum 2'
        Jejunum_2 = str2num(result(Je2_exist + 9 : newlines(Je2_end) - 2));
    end
    
    %Find Ileum 1
    Il1_exist = strfind(result, 'Ileum 1'); %index is where Ileum 1 is
    if isempty(Il1_exist) == 0 
        %index of end of line (+2)
        Il1_end = find(newlines>Il1_exist(1),1);
        %add 7 for length of the string 'Ileum 1'
        Ileum_1 = str2num(result(Il1_exist + 7 : newlines(Il1_end) - 2));
    end
    
    %Find Ileum 2
    Il2_exist = strfind(result, 'Ileum 2'); %index is where Ileum 2 is
    if isempty(Il2_exist) == 0 
        %index of end of line (+2)
        Il2_end = find(newlines>Il2_exist(1),1);
        %add 7 for length of the string 'Ileum 2'
        Ileum_2 = str2num(result(Il2_exist + 7 : newlines(Il2_end) - 2));
    end
    
    %Find Ileum 3
    Il3_exist = strfind(result, 'Ileum 3'); %index is where Ileum 3 is
    if isempty(Il3_exist) == 0 
        %index of end of line (+2)
        Il3_end = find(newlines>Il3_exist(1),1);
        %add 7 for length of the string 'Ileum 3'
        Ileum_3 = str2num(result(Il3_exist + 7 : newlines(Il3_end) - 2));
    end
 
    %Find Caecum
    Cae_exist = strfind(result, 'Caecum'); %index is where Caecum is
    if isempty(Cae_exist) == 0 
        %index of end of line (+2)
        Cae_end = find(newlines>Cae_exist(1),1);
        %add 6 for length of the string 'Caecum'
        Caecum = str2num(result(Cae_exist + 6 : newlines(Cae_end) - 2));
    end
    
    %Find Asc Colon
    Asc_exist = strfind(result, 'Asc Colon'); %index is where Asc Colon is
    if isempty(Asc_exist) == 0 
        %index of end of line (+2)
        Asc_end = find(newlines>Asc_exist(1),1);
        %add 9 for length of the string 'Asc Colon'
        Asc_Colon = str2num(result(Asc_exist + 9 : newlines(Asc_end) - 2));
    end

    %Find AmtAbs
    Amt_exist = strfind(result, 'AmtAbs'); %index is where AmtAbs is
    if isempty(Amt_exist) == 0 
        %index of end of line (+2)
        Amt_end = find(newlines>Amt_exist(1),1);
        %add 6 for length of the string 'AmtAbs'
        AmtAbs = str2num(result(Amt_exist + 6 : newlines(Amt_end) - 2));
    end
 %end of compartments   
 end
%end of data collection
end

    %Compiles results (Cmax, tmax, AUC (0-T) )
    output_simu_EE(j,:)=[cmax tmax AUC_0_t];           
    func_simu_EE(j,i,:)=(output_simu_EE(j,:)-func_simu_base(j,:))/ (auxiliary_points_frac(j,i) - base_points_frac(j,i));
    alloutput(j,:,i)=[cmax tmax AUC_0_t];
    
    %Compiles results(Cp-time data)
    Time_EE=time_EE(:,find(unique(conc_EE)));
    Conc_EE=conc_EE(:,find(unique(conc_EE)));
    dataEE=interp1(Time_EE(:,1:end),Conc_EE(:,1:end),Time,'spline');
    CpTime_data_EE=transpose([Time;dataEE]);
    all_time_EE(j,i,:)=CpTime_data_EE(:,1);
    output_simu_EE_Cp(j,:)=CpTime_data_EE(:,2);
    func_simu_EE_Cp(j,i,:)=(output_simu_EE_Cp(j,:)-func_simu_base_Cp(j,:))/ (auxiliary_points_frac(j,i) - base_points_frac(j,i));
    alloutput_Cp(j,:,i)=CpTime_data_EE(:,2);

    %Finds tmax from interpolation of Cp-time data
    dataEE_v2=interp1(Time_EE(:,1:end),Conc_EE(:,1:end),TimePoints,'spline');
    CpTime_data_EE_v2=transpose([TimePoints;dataEE_v2]);
    [findCmax,findTime]=max(CpTime_data_EE_v2(:,2));
    tmax2=CpTime_data_EE_v2(findTime,1);
    output_simu_EE_SigFig(j,:)=[cmax tmax2 AUC_0_t];
    func_simu_EE_SigFig(j,i,:)=(output_simu_EE_SigFig(j,:)-func_simu_base_SigFig(j,:))/(auxiliary_points_frac(j,i)-base_points_frac(j,i));
    alloutput_SigFig(j,:,i)=[cmax tmax2 AUC_0_t];

    %Displays which parameter set was run in GastroPlus
    string1=sprintf('GastroPlus run for Sample %s',num2str(j));    
    string2=sprintf(' for Parameter %s.',num2str(i));
    display(strcat(string1,string2))

    time_EE=[];
    conc_EE=[];
    Time_EE=[];
    Conc_EE=[];
    end

save(MATLABfile);
end
toc


%% Normalized EE Values

for k=1:num_of_output
    for j=1:repetition_of_sampling
    func_EE_pct(j,:,k)=func_simu_EE(j,:,k)/func_simu_base(j,k);
    func_EE_pct_SigFig(j,:,k)=func_simu_EE_SigFig(j,:,k)/func_simu_base(j,k);
    end
end

for k=1:length(Time)
    for j=1:repetition_of_sampling
    func_EE_Cp_pct(j,:,k)=func_simu_EE_Cp(j,:,k)/func_simu_base_Cp(j,k);
    func_Ee_Cp_pct_SigFig(j,:,k)=func_simu_EE_Cp_SigFig(j,:,k)/func_simu_base_Cp_SigFig(j,k);
    end
end


%% Calculation of sensitivity indices

%Initialize matrices
func_mu=zeros(num_of_factors,num_of_output);
func_mu_SigFig=zeros(num_of_factors,num_of_output);
func_sigma=zeros(num_of_factors,num_of_output);
func_sigma_SigFig=zeros(num_of_factors,num_of_output);
func_mu_star=zeros(num_of_factors,num_of_output);
func_mu_star_SigFig=zeros(num_of_factors,num_of_output);

% func_mu_star_pct=zeros(num_of_factors,num_of_output);
% func_mu_star_Cp=zeros(num_of_factors,length(Time));
% func_mu_star_Cp_pct=zeros(num_of_factors,length(Time));

for i=1:num_of_factors
    for j=1:repetition_of_sampling
    output_simu_EE_SigFig=alloutput_SigFig(:,:,i);
    func_simu_EE_SigFig(j,i,:)=(output_simu_EE_SigFig(j,:)-func_simu_base_SigFig(j,:))/(auxiliary_points_frac(j,i)-base_points_frac(j,i));
    end
end

for i=1:num_of_factors
    for j=1:num_of_output
        func_mu(i,j)=sum(func_simu_EE(:,i,j))/repetition_of_sampling;
        func_mu_SigFig(i,j)=sum(func_simu_EE_SigFig(:,i,j))/repetition_of_sampling;
        func_mu_star(i,j)=sum(abs(func_simu_EE(:,i,j)))/repetition_of_sampling;
        func_sigma(i,j)=sum((func_simu_EE(:,i,j)-func_mu(i,j)).^2)/repetition_of_sampling;
        func_mu_star_pct(i,j)=(sum(abs(func_simu_EE(:,i,j)))/repetition_of_sampling);
        func_mu_star_SigFig(i,j)=sum(abs(func_simu_EE_SigFig(:,i,j)))/repetition_of_sampling;
        func_sigma_SigFig(i,j)=sum((func_simu_EE_SigFig(:,i,j)-func_mu_SigFig(i,j)).^2)/repetition_of_sampling;
    end
    
%     for j=1:length(Time)
%         func_mu_star_Cp(i,j)=sum(abs(func_simu_EE_Cp(:,i,j)))/repetition_of_sampling;
%         func_mu_star_Cp_pct(i,j)=sum(abs(func_EE_Cp_pct(:,i,j)))/repetition_of_sampling;
%     end
end


%% Cutoff for Significant factors

% Most Significant Factors for Cmax, tmax, AUC
[Max_Mu_Cmax ParamNo_Mu_Cmax]=max(abs(func_mu(:,1)));
[Max_Sigma_Cmax ParamNo_Sigma_Cmax]=max(abs(func_sigma(:,1)));
[Max_Mu_Star_Cmax ParamNo_Mu_Star_Cmax]=max(abs(func_mu_star(:,1)));
[Max_Mu_tmax ParamNo_Mu_tmax]=max(abs(func_mu_SigFig(:,2)));
[Max_Sigma_tmax ParamNo_Sigma_tmax]=max(abs(func_sigma_SigFig(:,2)));
[Max_Mu_Star_tmax ParamNo_Mu_Star_tmax]=max(abs(func_mu_star_SigFig(:,2)));
[Max_Mu_AUC ParamNo_Mu_AUC]=max(abs(func_mu(:,3)));
[Max_Sigma_AUC ParamNo_Sigma_AUC]=max(abs(func_sigma(:,3)));
[Max_Mu_Star_AUC ParamNo_Mu_Star_AUC]=max(abs(func_mu_star(:,3)));

Output={'Cmax';'tmax';'AUC'};
ParamNo_Mu=[ParamNo_Mu_Cmax; ParamNo_Mu_tmax; ParamNo_Mu_AUC];
ParamNo_Sigma=[ParamNo_Sigma_Cmax; ParamNo_Sigma_tmax; ParamNo_Sigma_AUC];
ParamNo_Mu_Star=[ParamNo_Mu_Star_Cmax; ParamNo_Mu_Star_tmax; ParamNo_Mu_Star_AUC];

MOST_SIGNIFICANT=table(Output,ParamNo_Mu,ParamNo_Sigma,ParamNo_Mu_Star)

% Cutoff for Signficance
Cutoff_Mu_Cmax=0.1*Max_Mu_Cmax;
Cutoff_Sigma_Cmax=0.1*Max_Sigma_Cmax;
Cutoff_Mu_Star_Cmax=0.1*Max_Mu_Star_Cmax;
Cutoff_Mu_tmax=0.1*Max_Mu_tmax;
Cutoff_Sigma_tmax=0.1*Max_Sigma_tmax;
Cutoff_Mu_Star_tmax=0.1*Max_Mu_Star_tmax;
Cutoff_Mu_AUC=0.1*Max_Mu_AUC;
Cutoff_Sigma_AUC=0.1*Max_Sigma_AUC;
Cutoff_Mu_Star_AUC=0.1*Max_Mu_Star_AUC;

Significant_Mu_Cmax=find(abs(func_mu(:,1))>Cutoff_Mu_Cmax);
Significant_Sigma_Cmax=find(abs(func_sigma(:,1))>Cutoff_Sigma_Cmax);
Significant_Mu_Star_Cmax=find(abs(func_mu_star(:,1))>Cutoff_Mu_Star_Cmax);
Significant_Mu_tmax=find(abs(func_mu(:,2))>Cutoff_Mu_tmax);
Significant_Sigma_tmax=find(abs(func_sigma(:,2))>Cutoff_Sigma_tmax);
Significant_Mu_Star_tmax=find(abs(func_mu_star(:,2))>Cutoff_Mu_Star_tmax);
Significant_Mu_AUC=find(abs(func_mu(:,3))>Cutoff_Mu_AUC);
Significant_Sigma_AUC=find(abs(func_sigma(:,3))>Cutoff_Sigma_AUC);
Significant_Mu_Star_AUC=find(abs(func_mu_star(:,3))>Cutoff_Mu_Star_AUC);


Sum_Mu_Star_Cp=zeros(num_of_factors,1);
for i=1:num_of_factors
Sum_Mu_Star_Cp(i,:)=sum(func_mu_star_Cp(i,:));
end
Significant_Mu_Star_Cp=find(Sum_Mu_Star_Cp(:,1)>0);


%% Cutoff for Significant factors - NORMALIZED

% Most Significant Factors for Cmax, tmax, AUC
[Max_Mu_Cmax_pct ParamNo_Mu_Cmax_pct]=max(abs(func_mu_pct(:,1)));
[Max_Sigma_Cmax_pct ParamNo_Sigma_Cmax_pct]=max(abs(func_sigma_pct(:,1)));
[Max_Mu_Star_Cmax_pct ParamNo_Mu_Star_Cmax_pct]=max(abs(func_mu_star_pct(:,1)));
[Max_Mu_tmax_pct ParamNo_Mu_tmax_pct]=max(abs(func_mu_pct(:,2)));
[Max_Sigma_tmax_pct ParamNo_Sigma_tmax_pct]=max(abs(func_sigma_pct(:,2)));
[Max_Mu_Star_tmax_pct ParamNo_Mu_Star_tmax_pct]=max(abs(func_mu_star_pct(:,2)));
[Max_Mu_AUC_pct ParamNo_Mu_AUC_pct]=max(abs(func_mu_pct(:,3)));
[Max_Sigma_AUC_pct ParamNo_Sigma_AUC_pct]=max(abs(func_sigma_pct(:,3)));
[Max_Mu_Star_AUC_pct ParamNo_Mu_Star_AUC_pct]=max(abs(func_mu_star_pct(:,3)));

Output={'Cmax';'tmax';'AUC'; 'F'};
ParamNo_Mu_pct=[ParamNo_Mu_Cmax_pct; ParamNo_Mu_tmax_pct; ParamNo_Mu_AUC_pct];
ParamNo_Sigma_pct=[ParamNo_Sigma_Cmax_pct; ParamNo_Sigma_tmax_pct; ParamNo_Sigma_AUC_pct];
ParamNo_Mu_Star_pct=[ParamNo_Mu_Star_Cmax_pct; ParamNo_Mu_Star_tmax_pct; ParamNo_Mu_Star_AUC_pct];
MOST_SIGNIFICANT=table(Output,ParamNo_Mu_pct,ParamNo_Sigma_pct,ParamNo_Mu_Star_pct)

% Cutoff for Signficance
Cutoff_Mu_Cmax_pct=0.1*Max_Mu_Cmax_pct;
Cutoff_Sigma_Cmax_pct=0.1*Max_Sigma_Cmax_pct;
Cutoff_Mu_Star_Cmax_pct=0.1*Max_Mu_Star_Cmax_pct;
Cutoff_Mu_tmax_pct=0.1*Max_Mu_tmax_pct;
Cutoff_Sigma_tmax_pct=0.1*Max_Sigma_tmax_pct;
Cutoff_Mu_Star_tmax_pct=0.1*Max_Mu_Star_tmax_pct;
Cutoff_Mu_AUC_pct=0.1*Max_Mu_AUC_pct;
Cutoff_Sigma_AUC_pct=0.1*Max_Sigma_AUC_pct;
Cutoff_Mu_Star_AUC_pct=0.1*Max_Mu_Star_AUC_pct;

Significant_Mu_Cmax_pct=find(abs(func_mu_pct(:,1))>Cutoff_Mu_Cmax_pct);
Significant_Sigma_Cmax_pct=find(abs(func_sigma_pct(:,1))>Cutoff_Sigma_Cmax_pct);
Significant_Mu_Star_Cmax_pct=find(abs(func_mu_star_pct(:,1))>Cutoff_Mu_Star_Cmax_pct);
Significant_Mu_tmax_pct=find(abs(func_mu_pct(:,2))>Cutoff_Mu_tmax_pct);
Significant_Sigma_tmax_pct=find(abs(func_sigma_pct(:,2))>Cutoff_Sigma_tmax_pct);
Significant_Mu_Star_tmax_pct=find(abs(func_mu_star_pct(:,2))>Cutoff_Mu_Star_tmax_pct);
Significant_Mu_AUC_pct=find(abs(func_mu_pct(:,3))>Cutoff_Mu_AUC_pct);
Significant_Sigma_AUC_pct=find(abs(func_sigma_pct(:,3))>Cutoff_Sigma_AUC_pct);
Significant_Mu_Star_AUC_pct=find(abs(func_mu_star_pct(:,3))>Cutoff_Mu_Star_AUC_pct);

Sum_Mu_Star_Cp_pct=zeros(num_of_factors,1);
Sum_Mu_Star_RegAbs_pct=zeros(num_of_factors,1);
for i=1:num_of_factors
Sum_Mu_Star_Cp_pct(i,:)=sum(func_mu_star_Cp_pct(i,:));
end
Significant_Mu_Star_Cp_pct=find(Sum_Mu_Star_Cp_pct(:,1)>max(Sum_Mu_Star_Cp_pct(:,1))*0.01);


%% Generate figures for Mu Star

Labels={'St pH','St Vol','St Pore','St Porosity/Length','St TT',...
            'Duo pH','Duo Bile Salt','Duo Pore Radius','Duo Porosity/Length',...
            'J1 pH','J1 Bile Salt','J1 Pore Radius','J1 Porosity/Length',...
            'J2 Bile Salt','J2 Pore Radius','J2 Porosity/Length'...
            'I1 Bile Salt','I1 Pore Radius','I1 Porosity/Length',...
            'I2 Bile Salt','I2 Pore Radius','I2 Porosity/Length',...
            'I3 Bile Salt','I3 Pore Radius','I3 Porosity/Length',...
            'Ca pH', 'Ca Length', 'Ca Radius','Ca Pore Radius','Ca Porosity/Length',' Ca TT',...
            'Co pH', 'Co Length', 'Co Radius','Co Pore Radius','Co Porosity/Length', 'Co TT',...
            'FFV SI', 'FFV Col','Qh', 'SI Length','SI Radius','SI TT',...
            'Body Weight', '[Blood/Plasma] Ratio', 'Plasma Fup', 'CL', 'Vc','k12','k21','k13','k31'...
            'ASF C1', ' ASF C2', ' ASF C3', ' ASF C4','FPE Liver'};

figure
subplot(2,1,1)
bar(func_mu_star(:,1),'EdgeColor','k','FaceColor','g')
hold on
hline=refline(0,Cutoff_Mu_Star_Cmax)
hline.Color='red';
hline.LineStyle='--';
title('(A) C_{max}','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.XLim = [0 58];
%ax.YLim = [0 15];
hold off

subplot(2,1,2)
bar(func_mu_star(:,2),'EdgeColor','k','FaceColor','b')
hold on
hline=refline(0,Cutoff_Mu_Star_tmax)
hline.Color='red';
hline.LineStyle='--';
title('(B) t_{max}','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.YLabel.FontWeight='bold';
ax.XLim = [0 58];
%ax.YLim = [0 2];
hold off

figure
subplot(2,1,1)
bar(func_mu_star(:,3),'EdgeColor','k','FaceColor','r')
hold on
hline=refline(0,Cutoff_Mu_Star_AUC)
hline.Color='red';
hline.LineStyle='--';
title('(C) AUC_{0-t}','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.XLim = [0 58];
%ax.YLim = [0 200];
hold off

subplot(2,1,2)
bar(func_mu_star(:,6),'EdgeColor','k','FaceColor','y')
hold on
hline=refline(0,Cutoff_Mu_Star_F)
hline.Color='red';
hline.LineStyle='--';
title('(D) Bioavailability (F)','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\mu*';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.XLim=[0 58];
%ax.YLim=[0 20];
hold off


%% Generates figures for mu vs. sigma

sz=100;

figure
subplot(2,2,1)
%Referance line at mu=0
plot([0 0],[0 100],'k--','LineWidth',0.5)
%ACAT Model
hold on
scatter(func_mu(1,1),func_sigma(1,1),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
for i=2:39
    scatter(func_mu(i,1),func_sigma(i,1),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
end
for i=41:43
    scatter(func_mu(i,1),func_sigma(i,1),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
end
%ASF Model
for i=53:56
    scatter(func_mu(i,1),func_sigma(i,1),sz,'MarkerEdgeColor','k','MarkerFaceColor','b','LineWidth',1)
end
%PK Compartment Model
scatter(func_mu(40,1),func_sigma(40,1),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
for i=44:52
    scatter(func_mu(i,1),func_sigma(i,1),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
end
scatter(func_mu(57,1),func_sigma(57,1),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
title('(A) C_{max}','Color','black','FontSize',18)
ax=gca;
ax.YLabel.String='\sigma^2';
ax.YLabel.FontSize=18;
ax.XLabel.String='\mu';
ax.XLabel.FontSize=18;
ax.YLabel.FontWeight='bold';
ax.XLabel.FontWeight='bold';
ax.XAxis.FontSize=16;
ax.YAxis.FontSize=16;
ax.Box = 'on';
%ax.XLim=[-15 5];

subplot(2,2,2)
%Referance line at mu=0
plot([0 0],[0 0.05],'k--','LineWidth',0.5)
%ACAT Model
hold on
scatter(func_mu(1,2),func_sigma(1,2),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
for i=2:39
    scatter(func_mu(i,2),func_sigma(i,2),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
end
for i=41:43
    scatter(func_mu(i,2),func_sigma(i,2),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
end
%ASF Model
for i=53:56
    scatter(func_mu(i,2),func_sigma(i,2),sz,'MarkerEdgeColor','k','MarkerFaceColor','b','LineWidth',1)
end
%PK Compartment Model
scatter(func_mu(40,2),func_sigma(40,2),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
for i=44:52
    scatter(func_mu(i,2),func_sigma(i,2),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
end
scatter(func_mu(57,2),func_sigma(57,2),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
title('(B) t_{max}','Color','black','FontSize',18)
ax=gca;
ax.YLabel.String='\sigma^2';
ax.YLabel.FontSize=18;
ax.XLabel.String='\mu';
ax.XLabel.FontSize=18;
ax.YLabel.FontWeight='bold';
ax.XLabel.FontWeight='bold';
ax.XAxis.FontSize=16;
ax.YAxis.FontSize=16;
ax.Box = 'on';
%ax.XLim=[-1.5 1.5];

subplot(2,2,3)
%Referance line at mu=0
plot([0 0],[0 1500],'k--','LineWidth',0.5)
%ACAT Model
hold on
scatter(func_mu(1,3),func_sigma(1,3),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
for i=2:39
    scatter(func_mu(i,3),func_sigma(i,3),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
end
for i=41:43
    scatter(func_mu(i,3),func_sigma(i,3),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
end
%ASF Model
for i=53:56
    scatter(func_mu(i,3),func_sigma(i,3),sz,'MarkerEdgeColor','k','MarkerFaceColor','b','LineWidth',1)
end
%PK Compartment Model
scatter(func_mu(40,3),func_sigma(40,3),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
for i=44:52
    scatter(func_mu(i,3),func_sigma(i,3),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
end
scatter(func_mu(57,3),func_sigma(57,3),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
title('(C) AUC','Color','black','FontSize',18)
ax=gca;
ax.YLabel.String='\sigma^2';
ax.YLabel.FontSize=18;
ax.XLabel.String='\mu';
ax.XLabel.FontSize=18;
ax.YLabel.FontWeight='bold';
ax.XLabel.FontWeight='bold';
ax.XAxis.FontSize=16;
ax.YAxis.FontSize=16;
ax.Box = 'on';
%ax.XLim=[-200 50];

subplot(2,2,4)
%Referance line at mu=0
plot([0 0],[0 100],'k--','LineWidth',0.5)
%ACAT Model
hold on
scatter(func_mu(1,6),func_sigma(1,6),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
for i=2:39
    scatter(func_mu(i,6),func_sigma(i,6),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
end
for i=41:43
    scatter(func_mu(i,6),func_sigma(i,6),sz,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1)
end
%ASF Model
for i=53:56
    scatter(func_mu(i,6),func_sigma(i,6),sz,'MarkerEdgeColor','k','MarkerFaceColor','b','LineWidth',1)
end
%PK Compartment Model
scatter(func_mu(40,6),func_sigma(40,6),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
for i=44:52
    scatter(func_mu(i,6),func_sigma(i,6),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
end
scatter(func_mu(57,6),func_sigma(57,6),sz,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1)
title('(D) Bioavailability (F)','Color','black','FontSize',18)
ax=gca;
ax.YLabel.String='\sigma^2';
ax.YLabel.FontSize=18;
ax.XLabel.String='\mu';
ax.XLabel.FontSize=18;
ax.YLabel.FontWeight='bold';
ax.XLabel.FontWeight='bold';
ax.XAxis.FontSize=16;
ax.YAxis.FontSize=16;
ax.Box = 'on';
%ax.XLim=[-20 10];


%% Dynamic Sensitivity Indices - NORMALIZED

mu_star_Cp_pct=func_mu_star_Cp_pct(Significant_Mu_Star_Cp_pct,:);
Significant_Names_Cp_pct=names(Significant_Mu_Star_Cp_pct,:);

figure
plot(all_time_EE(10,:),mu_star_Cp_pct(1,:),'LineWidth',4,'Color',[rand rand rand])
hold on
for i=2:length(Significant_Names_Cp_pct)
    plot(all_time_EE(10,:),mu_star_Cp_pct(i,:),'LineWidth',4,'Color',[rand rand rand])
end
legend(Significant_Names_Cp_pct,'Location','eastoutside','FontSize',12);       
ax=gca;
ax.YLabel.String='Modified \mu*';
ax.YLabel.FontSize=18;
ax.XLabel.String='Time (hr)';
ax.XLabel.FontSize=18;
ax.YLabel.FontWeight='bold';
ax.XLabel.FontWeight='bold';
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Box = 'on'
ax.XLim=[0 24];
ax.XTick=0:4:24;
hold off


%% Plot Plasma concentration profiles

% time=horzcat(zeros(10,1),time_base)
% Cp=horzcat(zeros(10,1),func_simu_base_Cp)
% 
% figure
% plot(time(1,:),Cp(1,:),'LineWidth',2,'Color',[rand rand rand])
% hold on
% for i=2:repetition_of_sampling
%     plot(time(i,:),Cp(i,:),'LineWidth',2,'Color',[rand rand rand])
% end
% ax=gca;
% ax.YLabel.String='Plasma Concentration (mg/mL)';
% ax.YLabel.FontSize=18;
% ax.XLabel.String='Time (hr)';
% ax.XLabel.FontSize=18;
% ax.YLabel.FontWeight='bold';
% ax.XLabel.FontWeight='bold';
% ax.XAxis.FontSize=14;
% ax.YAxis.FontSize=14;
% ax.Box = 'on'
% ax.XLim=[0 96];
% ax.XTick=0:8:96;
% ax.YLim=[0 15];
% hold off


%% Generate figures for Mu and Sigma Bar Graphs

Labels={'St pH','St Vol','St Pore','St Porosity/Length','St TT',...
            'Duo pH','Duo Bile Salt','Duo Pore Radius','Duo Porosity/Length',...
            'J1 pH','J1 Bile Salt','J1 Pore Radius','J1 Porosity/Length',...
            'J2 Bile Salt','J2 Pore Radius','J2 Porosity/Length'...
            'I1 Bile Salt','I1 Pore Radius','I1 Porosity/Length',...
            'I2 Bile Salt','I2 Pore Radius','I2 Porosity/Length',...
            'I3 Bile Salt','I3 Pore Radius','I3 Porosity/Length',...
            'Ca pH', 'Ca Length', 'Ca Radius','Ca Pore Radius','Ca Porosity/Length',' Ca TT',...
            'Co pH', 'Co Length', 'Co Radius','Co Pore Radius','Co Porosity/Length', 'Co TT',...
            'FFV SI', 'FFV Col','Qh', 'SI Length','SI Radius','SI TT',...
            'Body Weight', '[Blood/Plasma] Ratio', 'Plasma Fup', 'CL', 'Vc','k12','k21','k13','k31',...
            'ASF C1', ' ASF C2', ' ASF C3', ' ASF C4','FPE Liver'};

figure
subplot(2,1,1)
bar(func_mu(:,1),'EdgeColor','k','FaceColor','g')
title('(A) \mu for C_{max}','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\mu';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.XLim = [0 58];

subplot(2,1,2)
bar(func_sigma(:,1),'EdgeColor','k','FaceColor','g')
title('(B) \sigma^2 for C_{max}','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\sigma^2';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.YLabel.FontWeight='bold';
ax.XLim = [0 58];

figure
subplot(2,1,1)
bar(func_mu(:,2),'EdgeColor','k','FaceColor','b')
title('(A) \mu for t_{max}','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\mu';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.XLim = [0 58];

subplot(2,1,2)
bar(func_sigma(:,2),'EdgeColor','k','FaceColor','b')
title('(B) \sigma^2 for t_{max}','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\sigma^2';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.YLabel.FontWeight='bold';
ax.XLim = [0 58];

figure
subplot(2,1,1)
bar(func_mu(:,3),'EdgeColor','k','FaceColor','r')
title('(A) \mu for AUC','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\mu';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.XLim = [0 58];

subplot(2,1,2)
bar(func_sigma(:,3),'EdgeColor','k','FaceColor','r')
title('(B) \sigma^2 for AUC','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\sigma^2';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.YLabel.FontWeight='bold';
ax.XLim = [0 58];

figure
subplot(2,1,1)
bar(func_mu(:,6),'EdgeColor','k','FaceColor','y')
title('(A) \mu for Bioavailability','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\mu';
ax.YLabel.FontWeight='bold';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.XLim = [0 58];

subplot(2,1,2)
bar(func_sigma(:,6),'EdgeColor','k','FaceColor','y')
title('(B) \sigma^2 for Bioavailability','Color','black','FontSize',18)
set(gca, 'XTick', 1:57, 'XTickLabel', Labels,'FontSize',16);
ax=gca;
ax.YLabel.String='\sigma^2';
ax.YLabel.FontSize=18;
ax.XTickLabelRotation = 45;
ax.YLabel.FontWeight='bold';
ax.XLim = [0 58];