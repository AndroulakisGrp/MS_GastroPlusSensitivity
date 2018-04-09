%Script for Sobol method
%edited July 28 2017 by Meg

clear;clc;close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code Capabilities:
    %Sobol sampling of ACAT and PK compartment model parameters
    %Incorporates correlations for underlying physiology for small intestine
    %Model Output: Cmax, tmax, AUC, Cp-time data, Fa, FDp, F, regional
    %absorption, plasma-concentration data
    %Calculates Sobol sensitivity indices (Si, S12, STi)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%REMEMBER TO UPDATE THE NUMBER OF FACTORS TO BE INCLUDED IN SAMPLING
%Selected factors based on the Morris Method

%% Set up for automation script
automation = 'C:\Users\megerle\Desktop\IPA_Group\Automation_Scripts\Parameter_Sensitivity\Sobol\Final\GastroPlus_automation_v2.exe';
excel = '\data_collection.xlsx';

%Identifies files to be uploaded into GastroPlus
%Upload dissolution file
a{6} = '0';
%Upload drug table
a{8} = '0';
%Upload pka table
a{9} = '0';

%Run simulation
a{1} = '1'; %Change to '0' if you don't want to run the simulation

%Identifies which GastroPlus results are copied into Excel
%Change to '0' if you dont want the data to be copied
a{2} = excel; %Copies PK summary data into Excel
a{3} = '0'; %Copies Cp-time data into Excel
a{10} = '0'; %Copies regional absorption data into Excel


%% Generate ACAT and PK compartment model sampling space

%Import default ACAT model file
[~, ~, phystest_A] = xlsread('phys_test_A.xlsx','phystest');
phystest_A(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),phystest_A)) = {''};
[~, ~, phystest_B] = xlsread('phys_test_B.xlsx','phystest');
phystest_B(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),phystest_B)) = {''};
[~, ~, phystest_ABi] = xlsread('phys_test_ABi.xlsx','phystest');
phystest_ABi(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),phystest_ABi)) = {''};

%Sampled Parameters
[values,names] = xlsread('input_parameters_Sobol.xlsx',4);
nominal_values=transpose(values);

%Computational Costs
num_of_factors = length(nominal_values); % number of input factors (sampled ACAT + PK compartment model parameters)
num_of_output = 1; % number of output variables (Cmax, Tmax, AUC, Fa, FDp, F)
repetition_of_sampling = 5000; % number of N, should be set to 500 or larger
Computational_costs=repetition_of_sampling*(num_of_factors+2);

%Specify limits for sampling
lower_bound=0.8*nominal_values; % specify lower bound
upper_bound=1.2*nominal_values; % specify upper bound

%Initialize matrices
%Base and Auxiliary Matrices
func_simu_base=zeros(repetition_of_sampling,num_of_output);
func_simu_auxiliary=zeros(repetition_of_sampling,num_of_output);

%Re-sampling Matrices
func_simu_temp=zeros(repetition_of_sampling,num_of_factors,num_of_output);

%Sobol sampling
temp_sample_points_p=sobolset(num_of_factors*2);
temp_sample_points_p = scramble(temp_sample_points_p,'MatousekAffineOwen');
temp_sample_points=net(temp_sample_points_p,repetition_of_sampling+1);
sample_points=zeros(repetition_of_sampling,num_of_factors*2);
 
for i = 1:repetition_of_sampling
    for j=1:num_of_factors
        sample_points(i,j) = lower_bound(j) + (upper_bound(j) - lower_bound(j)).*temp_sample_points(i+1,j);
        sample_points(i,num_of_factors+j) = lower_bound(j) + (upper_bound(j) - lower_bound(j)).*temp_sample_points(i+1,num_of_factors+j);
    end
end

%Unscaled values in base and auxiliary matrices
base_points=sample_points(:,1:num_of_factors);
auxiliary_points=sample_points(:,num_of_factors+1:2*num_of_factors);


%% Run GastroPlus for base matrix
    %Generate ACAT model files in base matrix
    %Update PK parameters in GastroPlus
    %Run GastroPlus for parameter sets in base matrix
    %Compile data for base matrix in MATLAB

tic

for i=1751%1:repetition_of_sampling

%Update physiology files for base and auxiliary matrices
    phystest_A(3)=cellstr('Physiology: Physiology_A ');
%     phystest_A(60)=cellstr(sprintf('Stomach pH =  %s ',num2str(base_points(i,4))));
%     phystest_A(61)=cellstr(sprintf('Stomach Volume =  %s ',num2str(base_points(i,2))));
%     phystest_A(67)=cellstr(sprintf('Stomach Comp Pore Radius = %s ',num2str(base_points(i,3))));
%     phystest_A(68)=cellstr(sprintf('Stomach Comp Porosity/Pore Length = %s ',num2str(base_points(i,4))));
%     phystest_A(69)=cellstr(sprintf('Stomach Transit Time = %s ',num2str(base_points(i,1))));
%     phystest_A(103)=cellstr(sprintf('Duodenum pH = %s ',num2str(base_points(i,6))));
%     phystest_A(109)=cellstr(sprintf('Duodenum Comp Bile = %s ',num2str(base_points(i,7))));
%     phystest_A(110)=cellstr(sprintf('Duodenum Comp Pore Radius = %s ',num2str(base_points(i,8))));
%     phystest_A(111)=cellstr(sprintf('Duodenum Comp Porosity/Pore Length = %s ',num2str(base_points(i,9))));
    phystest_A(146)=cellstr(sprintf('Jejunum 1 pH = %s ',num2str(base_points(i,1))));
%     phystest_A(152)=cellstr(sprintf('Jejunum 1 Comp Bile = %s ',num2str(base_points(i,11))));
%     phystest_A(153)=cellstr(sprintf('Jejunum 1 Comp Pore Radius = %s ',num2str(base_points(i,12))));
%     phystest_A(154)=cellstr(sprintf('Jejunum 1 Comp Porosity/Pore Length = %s ',num2str(base_points(i,13))));
%     phystest_A(195)=cellstr(sprintf('Jejunum 2 Comp Bile = %s ',num2str(base_points(i,14))));
%     phystest_A(196)=cellstr(sprintf('Jejunum 2 Comp Pore Radius = %s ',num2str(base_points(i,15))));
%     phystest_A(197)=cellstr(sprintf('Jejunum 2 Comp Porosity/Pore Length = %s ',num2str(base_points(i,16))));
%     phystest_A(238)=cellstr(sprintf('Ileum 1 Comp Bile = %s ',num2str(base_points(i,17))));
%     phystest_A(239)=cellstr(sprintf('Ileum 1 Comp Pore Radius = %s ',num2str(base_points(i,18))));
%     phystest_A(240)=cellstr(sprintf('Ileum 1 Comp Porosity/Pore Length = %s ',num2str(base_points(i,19))));
%     phystest_A(281)=cellstr(sprintf('Ileum 2 Comp Bile = %s ',num2str(base_points(i,20))));
%     phystest_A(282)=cellstr(sprintf('Ileum 2 Comp Pore Radius = %s ',num2str(base_points(i,21))));
%     phystest_A(283)=cellstr(sprintf('Ileum 2 Comp Porosity/Pore Length = %s ',num2str(base_points(i,22))));
%     phystest_A(324)=cellstr(sprintf('Ileum 3 Comp Bile = %s ',num2str(base_points(i,23))));
%     phystest_A(325)=cellstr(sprintf('Ileum 3 Comp Pore Radius = %s ',num2str(base_points(i,24))));
%     phystest_A(326)=cellstr(sprintf('Ileum 3 Comp Porosity/Pore Length = %s ',num2str(base_points(i,25))));
%     phystest_A(361)=cellstr(sprintf('Caecum pH = %s ',num2str(base_points(i,1))));
%     phystest_A(363)=cellstr(sprintf('Caecum Length = %s ',num2str(base_points(i,27))));
%     phystest_A(364)=cellstr(sprintf('Caecum Radius = %s ',num2str(base_points(i,2))));
%     phystest_A(368)=cellstr(sprintf('Caecum Comp Pore Radius = %s ',num2str(base_points(i,29))));
%     phystest_A(369)=cellstr(sprintf('Caecum Comp Porosity/Pore Length = %s ',num2str(base_points(i,30))));
%     phystest_A(370)=cellstr(sprintf('Caecum Transit Time = %s ',num2str(base_points(i,31))));
%     phystest_A(404)=cellstr(sprintf('Asc Colon pH = %s ',num2str(base_points(i,3))));
%     phystest_A(406)=cellstr(sprintf('Asc Colon Length = %s ',num2str(base_points(i,33))));
%     phystest_A(407)=cellstr(sprintf('Asc Colon Radius = %s ',num2str(base_points(i,3))));
%     phystest_A(411)=cellstr(sprintf('Asc Colon Comp Pore Radius = %s ',num2str(base_points(i,35))));
%     phystest_A(412)=cellstr(sprintf('Asc Colon Comp Porosity/Pore Length = %s ',num2str(base_points(i,36))));
%     phystest_A(413)=cellstr(sprintf('Asc Colon Transit Time = %s ',num2str(base_points(i,4))));
%     phystest_A(479)=cellstr(sprintf('Fasted State Volume Fraction =  %s ',num2str(base_points(i,4))));
%     phystest_A(480)=cellstr(sprintf('Fasted State Volume Fraction Col =  %s ',num2str(base_points(i,39))));
%     phystest_A(445)=cellstr(sprintf('Qh = %s ',num2str(base_points(i,40))));
    %Correlated Factors
%     phystest_A(105)=cellstr(sprintf('Duodenum Length = %s ',num2str(base_points(i,5)*0.0462)));
%     phystest_A(148)=cellstr(sprintf('Jejunum 1 Length = %s ',num2str((base_points(i,5)-base_points(i,5)*0.0462)/5)));
%     phystest_A(191)=cellstr(sprintf('Jejunum 2 Length = %s ',num2str((base_points(i,5)-base_points(i,5)*0.0462)/5)));
%     phystest_A(234)=cellstr(sprintf('Ileum 1 Length = %s ',num2str((base_points(i,5)-base_points(i,5)*0.0462)/5)));
%     phystest_A(277)=cellstr(sprintf('Ileum 2 Length = %s ',num2str((base_points(i,5)-base_points(i,5)*0.0462)/5)));
%     phystest_A(320)=cellstr(sprintf('Ileum 3 Length = %s ',num2str((base_points(i,5)-base_points(i,5)*0.0462)/5)));
    phystest_A(106)=cellstr(sprintf('Duodenum Radius = %s ',num2str(base_points(i,2)*1.6)));
    phystest_A(149)=cellstr(sprintf('Jejunum 1 Radius = %s ',num2str(base_points(i,2)*1.5)));
    phystest_A(192)=cellstr(sprintf('Jejunum 2 Radius = %s ',num2str(base_points(i,2)*1.34)));
    phystest_A(235)=cellstr(sprintf('Ileum 1 Radius = %s ',num2str(base_points(i,2)*1.18)));
    phystest_A(278)=cellstr(sprintf('Ileum 2 Radius = %s ',num2str(base_points(i,2)*1.01)));
    phystest_A(321)=cellstr(sprintf('Ileum 3 Radius = %s ',num2str(base_points(i,2)*0.85)));
    phystest_A(112)=cellstr(sprintf('Duodenum Transit Time = %s ',num2str(base_points(i,3)*0.0788)));
    phystest_A(155)=cellstr(sprintf('Jejunum 1 Transit Time = %s ',num2str(base_points(i,3)*0.2879)));
    phystest_A(198)=cellstr(sprintf('Jejunum 2 Transit Time = %s ',num2str(base_points(i,3)*0.2303)));
    phystest_A(241)=cellstr(sprintf('Ileum 1 Transit Time = %s ',num2str(base_points(i,3)*0.1788)));
    phystest_A(284)=cellstr(sprintf('Ileum 2 Transit Time = %s ',num2str(base_points(i,3)*0.1303)));
    phystest_A(327)=cellstr(sprintf('Ileum 3 Transit Time = %s ',num2str(base_points(i,3)*0.0939)));
    phystest_A(189)=cellstr(sprintf('Jejunum 2 pH = %s ',num2str(base_points(i,1)+0.2)));
    phystest_A(232)=cellstr(sprintf('Ileum 1 pH = %s ',num2str(base_points(i,1)+0.4)));
    phystest_A(275)=cellstr(sprintf('Ileum 2 pH = %s ',num2str(base_points(i,1)+0.7)));
    phystest_A(318)=cellstr(sprintf('Ileum 3 pH = %s ',num2str(base_points(i,1)+1.2)));
 
%Update ASF Model Coefficients, C1-C4
    phystest_A(9)=cellstr(sprintf('C1Alpha =  %s ',num2str(base_points(i,8))));
    phystest_A(10)=cellstr(sprintf('C2Alpha =  %s ',num2str(base_points(i,9))));
%     phystest_A(11)=cellstr(sprintf('C3Alpha =  %s ',num2str(base_points(i,16))));
%     phystest_A(12)=cellstr(sprintf('C4Alpha =  %s ',num2str(base_points(i,17))));
    
%Update ACAT model parameters and generate physiology files for Base Matrix
    filename_A='Physiology_A.txt';
    writetable(cell2table(phystest_A),filename_A,'WriteVariableNames',false,'Delimiter','\t');
    a{4}='\Physiology_A.txt';

%Update PK compartment parameters in GastroPlus for Base Matrix
        %Leave anything you don't want to change as nah
        nah = '54875';
        %Last entered values used for parameters set to 'nah'
        
    Body_weight = num2str(base_points(i,4)); %kg. Do not set this to 0, G+ will have an error and set weight to 70
    Blood_Plasma_Conc_Ratio = nah;
    Exp_Plasma_Fup = nah; % %
    CL = num2str(base_points(i,5)); %L/h
    Vc = num2str(base_points(i,6)); %L/kg
    K12 = num2str(base_points(i,7)); %1/h
    K21 = nah; %1/h
    K13 = num2str(base_points(i,11)); %1/h
    K31 = nah; %1/h
    Renal_clearance = num2str(base_points(i,10)); %L/h/kg
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
    func_simu_base(i,:)=[cmax];

    save('Furosemide_N5000_Cmax.mat');
display(sprintf('GastroPlus run for base Sample %s.',num2str(i)))
end
toc


%% Run GastroPlus for auxiliary matrix
    %Generate ACAT model files in auxiliary matrix
    %Update PK parameters in GastroPlus
    %Run GastroPlus for parameter sets in auziliary matrix
    %Compile data for auxiliary matrix in MATLAB

tic

for i=1:repetition_of_sampling

%Update physiology files for base and auxiliary matrices
    phystest_B(3)=cellstr('Physiology: Physiology_A ');
%     phystest_B(60)=cellstr(sprintf('Stomach pH =  %s ',num2str(base_points(i,4))));
%     phystest_B(61)=cellstr(sprintf('Stomach Volume =  %s ',num2str(base_points(i,2))));
%     phystest_B(67)=cellstr(sprintf('Stomach Comp Pore Radius = %s ',num2str(base_points(i,3))));
%     phystest_B(68)=cellstr(sprintf('Stomach Comp Porosity/Pore Length = %s ',num2str(base_points(i,4))));
%     phystest_B(69)=cellstr(sprintf('Stomach Transit Time = %s ',num2str(base_points(i,1))));
%     phystest_B(103)=cellstr(sprintf('Duodenum pH = %s ',num2str(base_points(i,6))));
%     phystest_B(109)=cellstr(sprintf('Duodenum Comp Bile = %s ',num2str(base_points(i,7))));
%     phystest_B(110)=cellstr(sprintf('Duodenum Comp Pore Radius = %s ',num2str(base_points(i,8))));
%     phystest_B(111)=cellstr(sprintf('Duodenum Comp Porosity/Pore Length = %s ',num2str(base_points(i,9))));
    phystest_B(146)=cellstr(sprintf('Jejunum 1 pH = %s ',num2str(base_points(i,1))));
%     phystest_B(152)=cellstr(sprintf('Jejunum 1 Comp Bile = %s ',num2str(base_points(i,11))));
%     phystest_B(153)=cellstr(sprintf('Jejunum 1 Comp Pore Radius = %s ',num2str(base_points(i,12))));
%     phystest_B(154)=cellstr(sprintf('Jejunum 1 Comp Porosity/Pore Length = %s ',num2str(base_points(i,13))));
%     phystest_B(195)=cellstr(sprintf('Jejunum 2 Comp Bile = %s ',num2str(base_points(i,14))));
%     phystest_B(196)=cellstr(sprintf('Jejunum 2 Comp Pore Radius = %s ',num2str(base_points(i,15))));
%     phystest_B(197)=cellstr(sprintf('Jejunum 2 Comp Porosity/Pore Length = %s ',num2str(base_points(i,16))));
%     phystest_B(238)=cellstr(sprintf('Ileum 1 Comp Bile = %s ',num2str(base_points(i,17))));
%     phystest_B(239)=cellstr(sprintf('Ileum 1 Comp Pore Radius = %s ',num2str(base_points(i,18))));
%     phystest_B(240)=cellstr(sprintf('Ileum 1 Comp Porosity/Pore Length = %s ',num2str(base_points(i,19))));
%     phystest_B(281)=cellstr(sprintf('Ileum 2 Comp Bile = %s ',num2str(base_points(i,20))));
%     phystest_B(282)=cellstr(sprintf('Ileum 2 Comp Pore Radius = %s ',num2str(base_points(i,21))));
%     phystest_B(283)=cellstr(sprintf('Ileum 2 Comp Porosity/Pore Length = %s ',num2str(base_points(i,22))));
%     phystest_B(324)=cellstr(sprintf('Ileum 3 Comp Bile = %s ',num2str(base_points(i,23))));
%     phystest_B(325)=cellstr(sprintf('Ileum 3 Comp Pore Radius = %s ',num2str(base_points(i,24))));
%     phystest_B(326)=cellstr(sprintf('Ileum 3 Comp Porosity/Pore Length = %s ',num2str(base_points(i,25))));
%     phystest_B(361)=cellstr(sprintf('Caecum pH = %s ',num2str(auxiliary_points(i,1))));
%     phystest_B(363)=cellstr(sprintf('Caecum Length = %s ',num2str(base_points(i,27))));
%     phystest_B(364)=cellstr(sprintf('Caecum Radius = %s ',num2str(auxiliary_points(i,2))));
%     phystest_B(368)=cellstr(sprintf('Caecum Comp Pore Radius = %s ',num2str(base_points(i,29))));
%     phystest_B(369)=cellstr(sprintf('Caecum Comp Porosity/Pore Length = %s ',num2str(base_points(i,30))));
%     phystest_B(370)=cellstr(sprintf('Caecum Transit Time = %s ',num2str(base_points(i,31))));
%     phystest_B(404)=cellstr(sprintf('Asc Colon pH = %s ',num2str(auxiliary_points(i,3))));
%     phystest_B(406)=cellstr(sprintf('Asc Colon Length = %s ',num2str(base_points(i,33))));
%     phystest_B(407)=cellstr(sprintf('Asc Colon Radius = %s ',num2str(base_points(i,3))));
%     phystest_B(411)=cellstr(sprintf('Asc Colon Comp Pore Radius = %s ',num2str(base_points(i,35))));
%     phystest_B(412)=cellstr(sprintf('Asc Colon Comp Porosity/Pore Length = %s ',num2str(base_points(i,36))));
%     phystest_B(413)=cellstr(sprintf('Asc Colon Transit Time = %s ',num2str(auxiliary_points(i,4))));
%     phystest_B(479)=cellstr(sprintf('Fasted State Volume Fraction =  %s ',num2str(base_points(i,4))));
%     phystest_B(480)=cellstr(sprintf('Fasted State Volume Fraction Col =  %s ',num2str(base_points(i,39))));
%     phystest_B(445)=cellstr(sprintf('Qh = %s ',num2str(base_points(i,40))));
    %Correlated Factors
%     phystest_B(105)=cellstr(sprintf('Duodenum Length = %s ',num2str(base_points(i,5)*0.0462)));
%     phystest_B(148)=cellstr(sprintf('Jejunum 1 Length = %s ',num2str((base_points(i,5)-base_points(i,5)*0.0462)/5)));
%     phystest_B(191)=cellstr(sprintf('Jejunum 2 Length = %s ',num2str((base_points(i,5)-base_points(i,5)*0.0462)/5)));
%     phystest_B(234)=cellstr(sprintf('Ileum 1 Length = %s ',num2str((base_points(i,5)-base_points(i,5)*0.0462)/5)));
%     phystest_B(277)=cellstr(sprintf('Ileum 2 Length = %s ',num2str((base_points(i,5)-base_points(i,5)*0.0462)/5)));
%     phystest_B(320)=cellstr(sprintf('Ileum 3 Length = %s ',num2str((base_points(i,5)-base_points(i,5)*0.0462)/5)));
    phystest_B(106)=cellstr(sprintf('Duodenum Radius = %s ',num2str(base_points(i,2)*1.6)));
    phystest_B(149)=cellstr(sprintf('Jejunum 1 Radius = %s ',num2str(base_points(i,2)*1.5)));
    phystest_B(192)=cellstr(sprintf('Jejunum 2 Radius = %s ',num2str(base_points(i,2)*1.34)));
    phystest_B(235)=cellstr(sprintf('Ileum 1 Radius = %s ',num2str(base_points(i,2)*1.18)));
    phystest_B(278)=cellstr(sprintf('Ileum 2 Radius = %s ',num2str(base_points(i,2)*1.01)));
    phystest_B(321)=cellstr(sprintf('Ileum 3 Radius = %s ',num2str(base_points(i,2)*0.85)));
    phystest_B(112)=cellstr(sprintf('Duodenum Transit Time = %s ',num2str(auxiliary_points(i,3)*0.0788)));
    phystest_B(155)=cellstr(sprintf('Jejunum 1 Transit Time = %s ',num2str(auxiliary_points(i,3)*0.2879)));
    phystest_B(198)=cellstr(sprintf('Jejunum 2 Transit Time = %s ',num2str(auxiliary_points(i,3)*0.2303)));
    phystest_B(241)=cellstr(sprintf('Ileum 1 Transit Time = %s ',num2str(auxiliary_points(i,3)*0.1788)));
    phystest_B(284)=cellstr(sprintf('Ileum 2 Transit Time = %s ',num2str(auxiliary_points(i,3)*0.1303)));
    phystest_B(327)=cellstr(sprintf('Ileum 3 Transit Time = %s ',num2str(auxiliary_points(i,3)*0.0939)));
    phystest_B(189)=cellstr(sprintf('Jejunum 2 pH = %s ',num2str(base_points(i,1)+0.2)));
    phystest_B(232)=cellstr(sprintf('Ileum 1 pH = %s ',num2str(base_points(i,1)+0.4)));
    phystest_B(275)=cellstr(sprintf('Ileum 2 pH = %s ',num2str(base_points(i,1)+0.7)));
    phystest_B(318)=cellstr(sprintf('Ileum 3 pH = %s ',num2str(base_points(i,1)+1.2)));
 
%Update ASF Model Coefficients, C1-C4
    phystest_B(9)=cellstr(sprintf('C1Alpha =  %s ',num2str(base_points(i,8))));
    phystest_B(10)=cellstr(sprintf('C2Alpha =  %s ',num2str(base_points(i,9))));
%     phystest_B(11)=cellstr(sprintf('C3Alpha =  %s ',num2str(auxiliary_points(i,16))));
%     phystest_B(12)=cellstr(sprintf('C4Alpha =  %s ',num2str(auxiliary_points(i,17))));
    
%Update ACAT model parameters and generate physiology files for Base Matrix
    filename_B='Physiology_B.txt';
    writetable(cell2table(phystest_B),filename_B,'WriteVariableNames',false,'Delimiter','\t');
    a{4}='\Physiology_B.txt';

%Update PK compartment parameters in GastroPlus for Base Matrix
        %Leave anything you don't want to change as nah
        nah = '54875';
        %Last entered values used for parameters set to 'nah'
        
    Body_weight = num2str(auxiliary_points(i,4)); %kg. Do not set this to 0, G+ will have an error and set weight to 70
    Blood_Plasma_Conc_Ratio = nah;
    Exp_Plasma_Fup = nah; % %
    CL = num2str(auxiliary_points(i,5)); %L/h
    Vc = num2str(auxiliary_points(i,6)); %L/kg
    K12 = num2str(auxiliary_points(i,7)); %1/h
    K21 = nah; %1/h
    K13 = num2str(auxiliary_points(i,11)); %1/h
    K31 = nah; %1/h
    Renal_clearance = num2str(auxiliary_points(i,10)); %L/h/kg
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
            time_B(m) = result5(time_i(m));
        end

        for m = 1:length(conc_i)
            conc_B(m) = result5(conc_i(m));
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
    func_simu_auxiliary(i,:)=[cmax];
    save('Furosemide_N5000_Cmax.mat');
display(sprintf('GastroPlus run for auxiliary Sample %s.',num2str(i)))
end

toc

%% Run GastroPlus to get all numbers for ABi
    %Generate ACAT model files for sensitivity index calculations
    %Update PK parameters in GastroPlus
    %Run GastroPlus for parameter sets in sensitivity index calculations
    %Compile data in MATLAB
    
tic

for i=1:num_of_factors

    temp=base_points;
    temp(:,i)=auxiliary_points(:,i);
    
    for j=1:repetition_of_sampling
    phystest_ABi(3)=cellstr('Physiology: Physiology_ABi ');
%     phystest_ABi(60)=cellstr(sprintf('Stomach pH =  %s ',num2str(temp(j,4))));
%     phystest_ABi(61)=cellstr(sprintf('Stomach Volume =  %s ',num2str(temp(j,2))));
%     phystest_ABi(67)=cellstr(sprintf('Stomach Comp Pore Radius = %s ',num2str(temp(j,3))));
%     phystest_ABi(68)=cellstr(sprintf('Stomach Comp Porosity/Pore Length = %s ',num2str(temp(j,4))));
%     phystest_ABi(69)=cellstr(sprintf('Stomach Transit Time =  %s ',num2str(temp(j,1))));
%     phystest_ABi(103)=cellstr(sprintf('Duodenum pH = %s ',num2str(temp(j,6))));
%     phystest_ABi(109)=cellstr(sprintf('Duodenum Comp Bile = %s ',num2str(temp(j,7))));
%     phystest_ABi(110)=cellstr(sprintf('Duodenum Comp Pore Radius = %s ',num2str(temp(j,8))));
%     phystest_ABi(111)=cellstr(sprintf('Duodenum Comp Porosity/Pore Length = %s ',num2str(temp(j,9))));
    phystest_ABi(146)=cellstr(sprintf('Jejunum 1 pH = %s ',num2str(temp(j,1))));
%     phystest_ABi(152)=cellstr(sprintf('Jejunum 1 Comp Bile = %s ',num2str(temp(j,11))));
%     phystest_ABi(153)=cellstr(sprintf('Jejunum 1 Comp Pore Radius = %s ',num2str(temp(j,12))));
%     phystest_ABi(154)=cellstr(sprintf('Jejunum 1 Comp Porosity/Pore Length = %s ',num2str(temp(j,13))));
%     phystest_ABi(195)=cellstr(sprintf('Jejunum 2 Comp Bile = %s ',num2str(temp(j,14))));
%     phystest_ABi(196)=cellstr(sprintf('Jejunum 2 Comp Pore Radius = %s ',num2str(temp(j,15))));
%     phystest_ABi(197)=cellstr(sprintf('Jejunum 2 Comp Porosity/Pore Length = %s ',num2str(temp(j,16))));
%     phystest_ABi(238)=cellstr(sprintf('Ileum 1 Comp Bile = %s ',num2str(temp(j,17))));
%     phystest_ABi(239)=cellstr(sprintf('Ileum 1 Comp Pore Radius = %s ',num2str(temp(j,18))));
%     phystest_ABi(240)=cellstr(sprintf('Ileum 1 Comp Porosity/Pore Length = %s ',num2str(temp(j,19))));
%     phystest_ABi(281)=cellstr(sprintf('Ileum 2 Comp Bile = %s ',num2str(temp(j,20))));
%     phystest_ABi(282)=cellstr(sprintf('Ileum 2 Comp Pore Radius = %s ',num2str(temp(j,21))));
%     phystest_ABi(283)=cellstr(sprintf('Ileum 2 Comp Porosity/Pore Length = %s ',num2str(temp(j,22))));
%     phystest_ABi(324)=cellstr(sprintf('Ileum 3 Comp Bile = %s ',num2str(temp(j,23))));
%     phystest_ABi(325)=cellstr(sprintf('Ileum 3 Comp Pore Radius = %s ',num2str(temp(j,24))));
%     phystest_ABi(326)=cellstr(sprintf('Ileum 3 Comp Porosity/Pore Length = %s ',num2str(temp(j,25))));
%     phystest_ABi(361)=cellstr(sprintf('Caecum pH = %s ',num2str(temp(j,1))));
%     phystest_ABi(363)=cellstr(sprintf('Caecum Length = %s ',num2str(temp(j,27))));
%     phystest_ABi(364)=cellstr(sprintf('Caecum Radius = %s ',num2str(temp(j,2))));
%     phystest_ABi(368)=cellstr(sprintf('Caecum Comp Pore Radius = %s ',num2str(temp(j,29))));
%     phystest_ABi(369)=cellstr(sprintf('Caecum Comp Porosity/Pore Length = %s ',num2str(temp(j,30))));
%     phystest_ABi(370)=cellstr(sprintf('Caecum Transit Time = %s ',num2str(temp(j,31))));
%     phystest_ABi(404)=cellstr(sprintf('Asc Colon pH = %s ',num2str(temp(j,3))));
%     phystest_ABi(406)=cellstr(sprintf('Asc Colon Length = %s ',num2str(temp(j,33))));
%     phystest_ABi(407)=cellstr(sprintf('Asc Colon Radius = %s ',num2str(temp(j,3))));
%     phystest_ABi(411)=cellstr(sprintf('Asc Colon Comp Pore Radius = %s ',num2str(temp(j,35))));
%     phystest_ABi(412)=cellstr(sprintf('Asc Colon Comp Porosity/Pore Length = %s ',num2str(temp(j,36))));
%     phystest_ABi(413)=cellstr(sprintf('Asc Colon Transit Time = %s ',num2str(temp(j,4))));
%     phystest_ABi(479)=cellstr(sprintf('Fasted State Volume Fraction =  %s ',num2str(temp(j,4))));
%     phystest_ABi(480)=cellstr(sprintf('Fasted State Volume Fraction Col =  %s ',num2str(temp(j,39))));
%     phystest_ABi(445)=cellstr(sprintf('Qh = %s ',num2str(temp(j,40))));
    
    %Correlated Factors
%     phystest_ABi(105)=cellstr(sprintf('Duodenum Length = %s ',num2str(temp(j,5)*0.0462)));
%     phystest_ABi(148)=cellstr(sprintf('Jejunum 1 Length = %s ',num2str((temp(j,5)-temp(j,5)*0.0462)/5)));
%     phystest_ABi(191)=cellstr(sprintf('Jejunum 2 Length = %s ',num2str((temp(j,5)-temp(j,5)*0.0462)/5)));
%     phystest_ABi(234)=cellstr(sprintf('Ileum 1 Length = %s ',num2str((temp(j,5)-temp(j,5)*0.0462)/5)));
%     phystest_ABi(277)=cellstr(sprintf('Ileum 2 Length = %s ',num2str((temp(j,5)-temp(j,5)*0.0462)/5)));
%     phystest_ABi(320)=cellstr(sprintf('Ileum 3 Length = %s ',num2str((temp(j,5)-temp(j,5)*0.0462)/5)));
    phystest_ABi(106)=cellstr(sprintf('Duodenum Radius = %s ',num2str(temp(j,2)*1.6)));
    phystest_ABi(149)=cellstr(sprintf('Jejunum 1 Radius = %s ',num2str(temp(j,2)*1.5)));
    phystest_ABi(192)=cellstr(sprintf('Jejunum 2 Radius = %s ',num2str(temp(j,2)*1.34)));
    phystest_ABi(235)=cellstr(sprintf('Ileum 1 Radius = %s ',num2str(temp(j,2)*1.18)));
    phystest_ABi(278)=cellstr(sprintf('Ileum 2 Radius = %s ',num2str(temp(j,2)*1.01)));
    phystest_ABi(321)=cellstr(sprintf('Ileum 3 Radius = %s ',num2str(temp(j,2)*0.85)));
    phystest_ABi(112)=cellstr(sprintf('Duodenum Transit Time = %s ',num2str(temp(j,3)*0.0788)));
    phystest_ABi(155)=cellstr(sprintf('Jejunum 1 Transit Time = %s ',num2str(temp(j,3)*0.2879)));
    phystest_ABi(198)=cellstr(sprintf('Jejunum 2 Transit Time = %s ',num2str(temp(j,3)*0.2303)));
    phystest_ABi(241)=cellstr(sprintf('Ileum 1 Transit Time = %s ',num2str(temp(j,3)*0.1788)));
    phystest_ABi(284)=cellstr(sprintf('Ileum 2 Transit Time = %s ',num2str(temp(j,3)*0.1303)));
    phystest_ABi(327)=cellstr(sprintf('Ileum 3 Transit Time = %s ',num2str(temp(j,3)*0.0939)));
    phystest_ABi(189)=cellstr(sprintf('Jejunum 2 pH = %s ',num2str(temp(j,1)+0.2)));
    phystest_ABi(232)=cellstr(sprintf('Ileum 1 pH = %s ',num2str(temp(j,1)+0.4)));
    phystest_ABi(275)=cellstr(sprintf('Ileum 2 pH = %s ',num2str(temp(j,1)+0.7)));
    phystest_ABi(318)=cellstr(sprintf('Ileum 3 pH = %s ',num2str(temp(j,1)+1.2)));

 %Update ASF Model Coefficients, C1-C4
    phystest_ABi(9)=cellstr(sprintf('C1Alpha =  %s ',num2str(temp(j,8))));
    phystest_ABi(10)=cellstr(sprintf('C2Alpha =  %s ',num2str(temp(j,9))));
%     phystest_ABi(11)=cellstr(sprintf('C3Alpha =  %s ',num2str(temp(j,16))));
%     phystest_ABi(12)=cellstr(sprintf('C4Alpha =  %s ',num2str(temp(j,17))));
    
%Save ACAT model files for Base and Auxiliary Matrix
    filename_ABi='Physiology_ABi.txt';
    writetable(cell2table(phystest_ABi),filename_ABi,'WriteVariableNames',false,'Delimiter','\t');
    a{4}='\Physiology_ABi.txt';

 %Update PK compartment parameters in GastroPlus for resampling matrices
        %Leave anything you don't want to change as nah
        nah = '54875';
        %Last entered values used for parameters set to 'nah'
    Body_weight = num2str(temp(j,4)); %kg. Do not set this to 0, G+ will have an error and set weight to 70
    Blood_Plasma_Conc_Ratio = nah;
    Exp_Plasma_Fup = nah; % %
    CL = num2str(temp(j,5)); %L/h
    Vc = num2str(temp(j,6)); %L/kg
    K12 = num2str(temp(j,7)); %1/
    K21 = nah; %1/h
    K13 = num2str(temp(j,11)); %1/h
    K31 = nah; %1/h
    Renal_clearance = num2str(temp(j,10)); %L/h/kg
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
            time_ABi(m) = result5(time_i(m));
        end

        for m = 1:length(conc_i)
            conc_ABi(m) = result5(conc_i(m));
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
    func_simu_temp(j,i,:)=[cmax];           
    
    save('Furosemide_N5000_Cmax.mat')
    %Displays which parameter set was run in GastroPlus
    string1=sprintf('GastroPlus run for Sample %s',num2str(j));    
    string2=sprintf(' for Parameter %s.',num2str(i));
    display(strcat(string1,string2))
    
    end
end
toc


%% Calculation of sensitivity indices

% Initialize matrices
func_E=zeros(1,num_of_output);  %E[x]
func_Ex2=zeros(1,num_of_output);  %E[x^2]

func_VxNew=zeros(num_of_factors,num_of_output);  %for Si
func_V_2nd=zeros(num_of_factors,num_of_factors,num_of_output); %for Sij
func_V_x=zeros(num_of_factors,num_of_output);  %for Sti

func_SiNew=zeros(num_of_factors,num_of_output);  %Si
func_Sij=zeros(num_of_factors,num_of_factors,num_of_output); %Sij
func_Sti=zeros(num_of_factors,num_of_output);  %Sti

for w=1:repetition_of_sampling
    for k=1:num_of_output %func
        func_Ex2(k)=func_Ex2(k)+(func_simu_base(w,k))^2/repetition_of_sampling;       
        func_E(k)=func_E(k)+func_simu_base(w,k)/repetition_of_sampling;
        
        for i=1:num_of_factors
            func_V_x(i,k)=func_V_x(i,k)+(func_simu_base(w,k)-func_simu_temp(w,i,k))^2/(2*repetition_of_sampling);        
            func_VxNew(i,k) = func_VxNew(i,k) + func_simu_auxiliary(w,k)*(func_simu_temp(w,i,k)-func_simu_base(w,k))/repetition_of_sampling;

            for j=1:num_of_factors
            func_V_2nd(j,i,k)=func_V_2nd(j,i,k)+(func_simu_temp(w,i,k)-func_simu_temp(w,j,k))^2/(2*repetition_of_sampling);
            end
        end
    end
    
end

func_V=func_Ex2-func_E.^2;  %real variance

for i=1:num_of_output
    func_Sti(:,i)=func_V_x(:,i)/func_V(i); % Eq (f)
    func_SiNew(:,i)=func_VxNew(:,i)/func_V(i); % Eq (b)    
    func_Sij(:,:,i)=func_V_2nd(:,:,i)/func_V(i);
end


%% Create a table of the results

filename='Sobol_APAP_IR_N1000_Cmax.xlsx';

Cmax=func_SiNew(:,1);
SiNew=table(names, Cmax);
writetable(SiNew, filename,'Sheet','Si_PK','WriteVariableNames',1)
Cmax=func_Sij(:,:,1);
Sij=table(names, Cmax);
writetable(Sij, filename,'Sheet','Sij_Cmax','WriteVariableNames',1)
Cmax=func_Sti(:,1);
Sti=table(names, Cmax);
writetable(Sti, filename,'Sheet','Sti_PK','WriteVariableNames',1);


%% Cutoff for Significant factors

% Most Significant Factors for Cmax, tmax, AUC
[Max_Si_Cmax ParamNo_Si_Cmax]=max(abs(func_SiNew(:,1)));
[Max_Sti_Cmax ParamNo_Sti_Cmax]=max(abs(func_Sti(:,1)));

Output={'Cmax'};
ParamNo_Si=[ParamNo_Si_Cmax];
ParamNo_Sti=[ParamNo_Sti_Cmax];

MOST_SIGNIFICANT=table(Output,ParamNo_Si,ParamNo_Sti)

% Cutoff for Signficance
Cutoff_Si_Cmax=0.1*Max_Si_Cmax;
Cutoff_Sti_Cmax=0.1*Max_Sti_Cmax;

Significant_Si_Cmax=find(abs(func_SiNew(:,1))>Cutoff_Si_Cmax);
Significant_Sti_Cmax=find(abs(func_Sti(:,1))>Cutoff_Sti_Cmax);


%% Tensity Plots

%First Order and Total Effects - Cmax
A = horzcat(func_SiNew(:,1),func_Sti(:,1));
reorder=vertcat(A(1:3,:),A(8:9,:),A(4,:),A(6:7,:),A(11,:),A(5,:),A(10,:));
reorder_names=vertcat(names(1:3),names(8:9),names(4),names(6:7),names(11),names(5),names(10));

XaxisArray = {'First Order';'Total Effects'};
YaxisArray = reorder_names;
figure()
imagesc(reorder)
colormap(flipud(gray))
colorbar
set(gca, 'XTick', 1:2);
set(gca,'Xticklabel', XaxisArray,'FontSize',16);
set(gca, 'Ytick', 1:num_of_factors);
set(gca, 'Yticklabel', YaxisArray,'FontSize',16);
xlabel('Sensitivity Measures','FontSize',16,'FontWeight','bold');
ylabel('Input factors','FontSize',16,'FontWeight','bold');
% title('(A) Furosemide C_{max} First Order and Total Effects','FontSize',14)
set(gca,'XTickLabelRotation',0)

% % Total Effects -Cmax
% A = horzcat(func_Sti(:,1));
% XaxisArray = {'C_{max}'};
% YaxisArray = names;
% figure()
% imagesc(A)
% colormap(gray)
% colorbar
% set(gca, 'XTick', 1:num_of_output);
% set(gca,'Xticklabel', XaxisArray);
% set(gca, 'Ytick', 1:num_of_factors);
% set(gca, 'Yticklabel', YaxisArray);
% xlabel('Output variables');
% ylabel('Input factors');
% title('APAP IR Tablet - Total Effects')
% set(gca,'XTickLabelRotation',45)

%Second Order Effects - Cmax
% A = func_Sij(:,:,1);
% reorder_rows=vertcat(A(1:3,:),A(8:9,:),A(4,:),A(6:7,:),A(11,:),A(5,:),A(10,:));
% reorder=horzcat(reorder_rows(:,1:3),reorder_rows(:,8:9),reorder_rows(:,4),reorder_rows(:,6:7),reorder_rows(:,11),reorder_rows(:,5),reorder_rows(:,10));
% XaxisArray = reorder_names;
% YaxisArray = reorder_names;
% figure()
% imagesc(reorder)
% colormap(parula)
% colorbar
% set(gca, 'XTick', 1:num_of_factors);
% set(gca,'Xticklabel', XaxisArray,'FontSize',16);
% set(gca, 'Ytick', 1:num_of_factors);
% set(gca, 'Yticklabel', YaxisArray,'FontSize',16);
% xlabel('Input Factors','FontSize',16,'FontWeight','bold');
% ylabel('Input Factors','FontSize',16,'FontWeight','bold');
% % title('(B) Furosemide C_{max} Second Order Effects','Fontsize',14)
% set(gca,'XTickLabelRotation',45)


%% Bootstrapping Sensitivity Indices Standard Error

se_Si=zeros(num_of_factors,num_of_output);
se_Sti=zeros(num_of_factors,num_of_output);
se_Sij=zeros(num_of_factors,num_of_factors,num_of_output);
Convergence_Si=zeros(num_of_factors,num_of_output);
Convergence_Sti=zeros(num_of_factors,num_of_output);
Convergence_Sij=zeros(num_of_factors,num_of_factors,num_of_output);

func_base=func_simu_base;
func_aux=func_simu_auxiliary;

for i=1:num_of_factors
    for j=1:num_of_output
    
    func_temp=func_simu_temp(:,i,j);
    func_temp_i=func_simu_temp(:,i,j);
  
    rng default
    [bootstat_Si,bootsam_Si]=bootstrp(10000,@func_Si,func_temp,func_aux,func_base);    
    se_Si(i,j) = std(bootstat_Si)/sqrt(repetition_of_sampling);

    [bootstat_Sti,bootsam_Sti]=bootstrp(10000,@func_Sti_bootstrap,func_temp,func_base);    
    se_Sti(i,j) = std(bootstat_Sti)/sqrt(repetition_of_sampling);
    
        for k=1:num_of_factors       
        func_temp_j=func_simu_temp(:,k,j);
        [bootstat_Sij,bootsam_Sij]=bootstrp(10000,@func_Sij_bootstrap,func_temp_i,func_temp_j,func_base);    
        se_Sij(i,k,j) = std(bootstat_Sij)/sqrt(repetition_of_sampling);  
        end
    end
    
end

% Convergence
Cutoff_Si=func_SiNew*0.1;
Cutoff_Sti=func_Sti*0.1;
Cutoff_Sij=func_Sij*0.1;

Convergence_Si=le(1.96*se_Si,Cutoff_Si);
Convergence_Sti=le(1.96*se_Sti,Cutoff_Sti);
Convergence_Sij=le(1.96*se_Sij,Cutoff_Sij);

SivsSti=le(func_SiNew, func_Sti);
sumSi=sum(func_SiNew);
sumSti=sum(func_Sti);


%% Correction of Sij to remove first order effects
func_Sij_corrected=zeros(num_of_factors,num_of_factors,num_of_output);
func_SiNew_corrected=zeros(num_of_factors,1);

for i=1:num_of_factors
if func_SiNew(i)>0
    func_SiNew_corrected(i)=func_SiNew(i);
else
    func_SiNew_corrected(i)=0;
end
end
    
for i=1:num_of_factors
    for j=1:num_of_factors
    func_Sij_corrected(i,j)=func_Sij(i,j)-func_SiNew_corrected(i)-func_SiNew_corrected(j);
    end
end

for i=1:num_of_factors
    func_Sij_corrected(i,i)=0;
end

%Second Order Effects - Cmax
A = func_Sij_corrected(:,:,1);
reorder_rows=vertcat(A(1:3,:),A(8:9,:),A(4,:),A(6:7,:),A(11,:),A(5,:),A(10,:));
reorder=horzcat(reorder_rows(:,1:3),reorder_rows(:,8:9),reorder_rows(:,4),reorder_rows(:,6:7),reorder_rows(:,11),reorder_rows(:,5),reorder_rows(:,10));
XaxisArray = reorder_names;
YaxisArray = reorder_names;
figure()
imagesc(reorder)
colormap(parula)
colorbar
set(gca, 'XTick', 1:num_of_factors);
set(gca,'Xticklabel', XaxisArray,'FontSize',16);
set(gca, 'Ytick', 1:num_of_factors);
set(gca, 'Yticklabel', YaxisArray,'FontSize',16);
xlabel('Input Factors','FontSize',16,'FontWeight','bold');
ylabel('Input Factors','FontSize',16,'FontWeight','bold');
% title('(B) Furosemide C_{max} Second Order Effects','Fontsize',14)
set(gca,'XTickLabelRotation',45)

%% Manuscript Figure

%First Order and Total Effects - Cmax
A = horzcat(func_SiNew(:,1),func_Sti(:,1));
reorder=vertcat(A(1:3,:),A(8:9,:),A(4,:),A(6:7,:),A(11,:),A(5,:),A(10,:));
reorder_names=vertcat(names(1:3),names(8:9),names(4),names(6:7),names(11),names(5),names(10));

XaxisArray = {'First Order';'Total Effects'};
YaxisArray = reorder_names;
figure()
subplot(1,2,1)
imagesc(reorder)
colormap(flipud(gray))
colorbar
set(gca, 'XTick', 1:2);
set(gca,'Xticklabel', XaxisArray,'FontSize',16);
set(gca, 'Ytick', 1:num_of_factors);
set(gca, 'Yticklabel', YaxisArray,'FontSize',16);
xlabel('Sensitivity Measures','FontSize',16,'FontWeight','bold');
ylabel('Input factors','FontSize',16,'FontWeight','bold');
% title('(A) Furosemide C_{max} First Order and Total Effects','FontSize',14)
set(gca,'XTickLabelRotation',0)

%Second Order Effects - Cmax
A = func_Sij_corrected(:,:,1);
reorder_rows=vertcat(A(1:3,:),A(8:9,:),A(4,:),A(6:7,:),A(11,:),A(5,:),A(10,:));
reorder=horzcat(reorder_rows(:,1:3),reorder_rows(:,8:9),reorder_rows(:,4),reorder_rows(:,6:7),reorder_rows(:,11),reorder_rows(:,5),reorder_rows(:,10));
XaxisArray = reorder_names;
YaxisArray = reorder_names;
subplot(1,2,2)
imagesc(reorder)
colormap(flipud(gray))
colorbar
set(gca, 'XTick', 1:num_of_factors);
set(gca,'Xticklabel', XaxisArray,'FontSize',16);
set(gca, 'Ytick', 1:num_of_factors);
set(gca, 'Yticklabel', YaxisArray,'FontSize',16);
xlabel('Input Factors','FontSize',16,'FontWeight','bold');
ylabel('Input Factors','FontSize',16,'FontWeight','bold');
% title('(B) Furosemide C_{max} Second Order Effects','Fontsize',14)
set(gca,'XTickLabelRotation',45)