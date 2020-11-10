%%
clc
clear
close all
%%


[fileNameInit, pathNameInit] = uigetfile('*.txt');
fileNameInitial = fullfile(pathNameInit, fileNameInit);
fileLists = dir(fullfile(pathNameInit, '*.txt'));

scanResults =regexp({fileLists.name},[fileNameInit(1:8) , '.p'], 'match');
index_plansum = find(~cellfun(@isempty,scanResults));


% Basement
summary_cell = {'GTV;cc'	'iGTV;cc'	'ITV(CTV);cc'	'PTV;cc'	'Lung;cc'	'Esophagus;cc'	'Heart;cc'	'CTVmax'	'CTVmin',...
    'CTV95%'	'CTV100%'	'PTVmax'	'PTVmin'	'PTV95%'	'PTV100%'	'lungV5'	'lungV10', ...
    'lungV20'	'MLD'	'EsoDmax'	'EsoV45'	'EsoV55'	'EsoV66'	'MHD'	'Heart_V30'	'Heart_V45'	'Heart_V50'	'CordDmax'};


% Initial plan
hfigure = figure(1);
[Whole_DVH, Prescribed_Dose, Structure_Name,Volume,Dose_Cover,Sampling_Cover,...
    Min_Dose,Max_Dose,Mean_Dose,Modal_Dose,Median_Dose,...
    STD,Equi_Sphere_Diamr,Conformity_Index,Gradient_Measure,...
    V5_Set, V10_Set, V20_Set, V30_Set, V45_Set, V50_Set, V55_Set,...
        V66_Set, V95_Set, V100_Set] = read_DVH_Eclipse_TPS_201027(fileNameInitial ,hfigure,'--s', 'init');


% Volume
IndexC = strfind(Structure_Name,'GTV');
Index = find(not(cellfun('isempty',IndexC)));
summary_cell{2,1} = Volume(Index);

IndexC = strfind(Structure_Name,'iGTV');
Index = find(not(cellfun('isempty',IndexC)));
summary_cell{2,2} = Volume(Index);

IndexC = strfind(Structure_Name,'CTV');
Index_CTV = find(not(cellfun('isempty',IndexC)));
summary_cell{2,3} = Volume(Index_CTV);

IndexC = strfind(Structure_Name,'PTV_4500');
Index = find(not(cellfun('isempty',IndexC)));
summary_cell{2,4} = Volume(Index);

IndexC = strfind(Structure_Name,'Lungs');
Index = find(not(cellfun('isempty',IndexC)));
summary_cell{2,5} = Volume(Index);

IndexC = strfind(Structure_Name,'Esophagus');
Index = find(not(cellfun('isempty',IndexC)));
summary_cell{2,6} = Volume(Index);

IndexC = strfind(Structure_Name,'Heart');
Index = find(not(cellfun('isempty',IndexC)));
summary_cell{2,7} = Volume(Index);



% Plan sum
if ~isempty(index_plansum)
    fileNamePlanSum = fullfile(pathNameInit, fileLists (index_plansum).name);
    
    hfigure = figure(2);
    [Whole_DVH_sumplan, Prescribed_Dose_sumplan, Structure_Name_sumplan,Volume_sumplan,Dose_Cover_sumplan,Sampling_Cover_sumplan,...
        Min_Dose_sumplan,Max_Dose_sumplan,Mean_Dose_sumplan,Modal_Dose_sumplan,Median_Dose_sumplan,...
        STD_sumplan,Equi_Sphere_Diamr_sumplan,Conformity_Index_sumplan,Gradient_Measure_sumplan, ...
        V5_Set_sumplan, V10_Set_sumplan, V20_Set_sumplan, V30_Set_sumplan, V45_Set_sumplan, V50_Set_sumplan, V55_Set_sumplan,...
        V66_Set_sumplan, V95_Set_sumplan, V100_Set_sumplan] = read_DVH_Eclipse_TPS_201027_Absolute(fileNamePlanSum ,6480, hfigure,'--s', 'plansum');
    
    % CTV
    IndexC = strfind(Structure_Name_sumplan,'CTV');
    Index_CTV = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,8}= (Max_Dose_sumplan(Index_CTV))./100;  % cGy
    summary_cell{2,9}= (Min_Dose_sumplan(Index_CTV))./100;  % cGy
    
    
    summary_cell{2,10}= (V95_Set_sumplan(Index_CTV));
    summary_cell{2,11}= (V100_Set_sumplan(Index_CTV));
    
    % iGTV
    a=0;
    
    % PTV
    IndexC = strfind(Structure_Name_sumplan,'PTV');
    Index_PTV = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,12}= (Max_Dose_sumplan(Index_PTV(1)))./100;  % cGy
    summary_cell{2,13}= (Min_Dose_sumplan(Index_PTV(1)))./100;  % cGy
    
    summary_cell{2,14}= (V95_Set_sumplan(Index_PTV(1)));
    summary_cell{2,15}= (V100_Set_sumplan(Index_PTV(1)));
    
    
    % Lung
    IndexC = strfind(Structure_Name_sumplan,'Lungs');
    Index_Lung = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,16}= (V5_Set_sumplan(Index_Lung(1)));
    summary_cell{2,17}= (V10_Set_sumplan(Index_Lung(1)));
    summary_cell{2,18}= (V20_Set_sumplan(Index_Lung(1)));
    summary_cell{2,19}= (Mean_Dose_sumplan(Index_Lung(1)))./100;
    
    
    
    % Esophagus
    IndexC = strfind(Structure_Name_sumplan,'Esophagus');
    Index_Eso = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,20}= (Max_Dose_sumplan(Index_Eso(1)))/100;
    summary_cell{2,21}= (V45_Set_sumplan(Index_Eso(1)));
    summary_cell{2,22}= (V55_Set_sumplan(Index_Eso(1)));
    summary_cell{2,23}= (V66_Set_sumplan(Index_Eso(1)));
    
    
    % Heart
    IndexC = strfind(Structure_Name_sumplan,'Heart');
    Index_Heart = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,24}= (Mean_Dose_sumplan(Index_Heart(1)))/100
    summary_cell{2,25}= (V30_Set_sumplan(Index_Heart(1)));
    summary_cell{2,26}= (V45_Set_sumplan(Index_Heart(1)));
    summary_cell{2,27}= (V50_Set_sumplan(Index_Heart(1)));
    
    % Spinal code
    IndexC = strfind(Structure_Name_sumplan,'SpinalCord');
    Index_cord = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,28} = Max_Dose_sumplan(Index_cord)/100;
    
else
    % Using inital DVH
    % CTV
    IndexC = strfind(Structure_Name,'CTV');
    Index_CTV = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,8}= (Max_Dose(Index_CTV))./100.*str2double(Prescribed_Dose{1})./100;  % Gy
    summary_cell{2,9}= (Min_Dose(Index_CTV))./100.*str2double(Prescribed_Dose{1})./100;  % Gy
    
    
    summary_cell{2,10}= (V95_Set(Index_CTV));
    summary_cell{2,11}= (V100_Set(Index_CTV));
    
    
    % PTV
    IndexC = strfind(Structure_Name,'PTV');
    Index_PTV = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,12}= (Max_Dose(Index_PTV(1)))./100.*str2double(Prescribed_Dose{1})./100;  % Gy
    summary_cell{2,13}= (Min_Dose(Index_PTV(1)))./100.*str2double(Prescribed_Dose{1})./100;  % Gy
    
    summary_cell{2,14}= (V95_Set(Index_PTV(1)));
    summary_cell{2,15}= (V100_Set(Index_PTV(1)));
    
    
    % Lung
    IndexC = strfind(Structure_Name,'Lungs');
    Index_Lung = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,16}= (V5_Set(Index_Lung(1)));
    summary_cell{2,17}= (V10_Set(Index_Lung(1)));
    summary_cell{2,18}= (V20_Set(Index_Lung(1)));
    summary_cell{2,19}= (Mean_Dose(Index_Lung(1)))./100.*str2double(Prescribed_Dose{1})./100;  % Gy
    
    
    
    % Esophagus
    IndexC = strfind(Structure_Name,'Esophagus');
    Index_Eso = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,20}= (Max_Dose(Index_Eso(1)))/100.*str2double(Prescribed_Dose{1})./100;  % Gy;
    summary_cell{2,21}= (V45_Set(Index_Eso(1)));
    summary_cell{2,22}= (V55_Set(Index_Eso(1)));
    summary_cell{2,23}= (V66_Set(Index_Eso(1)));
    
    
    % Heart
    IndexC = strfind(Structure_Name,'Heart');
    Index_Heart = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,24}= (Mean_Dose(Index_Heart(1)))/100.*str2double(Prescribed_Dose{1})./100;  % Gy;
    summary_cell{2,25}= (V30_Set(Index_Heart(1)));
    summary_cell{2,26}= (V45_Set(Index_Heart(1)));
    summary_cell{2,27}= (V50_Set(Index_Heart(1)));
    
    % Spinal code
    IndexC = strfind(Structure_Name,'SpinalCord');
    Index_cord = find(not(cellfun('isempty',IndexC)));
    summary_cell{2,28} = Max_Dose(Index_cord)/100.*str2double(Prescribed_Dose{1})./100;  % Gy;
    
    
end







































