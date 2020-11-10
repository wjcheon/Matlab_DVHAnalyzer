function [Whole_DVH, PrescribedDose, Structure_Name,Volume,Dose_Cover,Sampling_Cover,...
    Min_Dose,Max_Dose,Mean_Dose,Modal_Dose,Median_Dose,...
    STD,Equi_Sphere_Diamr,Conformity_Index,Gradient_Measure,...
    V5_Set, V10_Set, V20_Set, V30_Set, V45_Set, V50_Set, V55_Set, V66_Set, V95_Set, V100_Set] = read_DVH_Eclipse_TPS_201027(filename, hfigure_, marker_, type_)


%-------------------------------
% Filename  read_DVH_Eclipse
%
% Data         25th of May 2017
% Author      V.Caillet - Royal North Shore Hospital - St Leonards - Sydney AUS
%
% Purpose   Read the DVH text file exported from the Eclipse Treatment
%                   System
%
% Input        DVH textfile exported from Eclipse
%
% Output      'Whole_DVH ': Matrice of all the DVH.
%                     Number of colums of "Whole_Data" = Number of structures * Number of
%                     columns in text file.
%                    Other output are the specific output from each
%                    structure (e.g. Max dose, min dose)
%
%
% Example    filename = /Path to the text file here/Test.txt
%                     [Structure_Name,Volume,Dose_Cover,Sampling_Cover,...
%                     Min_Dose,Max_Dose,Mean_Dose,Modal_Dose,Median_Dose,...
%                     STD,Equi_Sphere_Diamr,Conformity_Index,Gradient_Measure]...
%                     = read_DVH_Eclipse_3(filename);
%
% Notes       This code was made to provide help for users. I did not find
%                   the code anywhere else online and thought that would be
%                   very helpful. Not being a programmer, there will be
%                   some errors in the code. Please don't use it for clinical decisions. The code
%                   should be able to find the number of columns in the
%                   data (it works for 2 and 3 columns). I kept the code
%                   PURPOSELY into one function so that it is easier to
%                   understand what is going on if someone not fully
%                   initiated to Matlab decides to modify it.
%
%                  Cases where the code will not work are the following
%                  1. All the DVH must have the same size. Maximum dose
%                  should have a '0' values otherwise. Make sure to export
%                  with same binning (Let's say every 0.5 Gy).
%                  2. The code WILL NOT WORK unless there is a 'Ratio of
%                  Total Structure Volume' sentennce in it right before the beginning
%                  of the number. Find the line name right before the
%                  beginning of the actual dvh numbers. Careful if there
%                  are brackets (e.g.Volume [cm³]) in which case you will
%                  need to add a '\' before the bracket (e.g. Volume
%                  \[cm³]).
%
%-----------------------------------------

fid = fopen(filename,'r'); %open any files
if fid<0; error('File did not open'); end

disp('--------------------------------------')
disp('File opened succesfully... Reading the data')

Structure_Name_Number = 1;
lineIndex = 1; Organs = 1; n=0;
nextline = fgetl(fid); % get the first line

while ~feof(fid)
    while 1
        if isempty(nextline)
            nextline = fgetl(fid); % At the end of the DVH numbers, there will be a space.
        end
        if strncmp(nextline, 'Prescribed dose', 15)
            a=0;
            PrescribedDose{Structure_Name_Number} = nextline;
        end
        if strncmp(nextline,'Structure:', 9)
            disp(['Reading structure ' , num2str(Structure_Name_Number)])
            Structure_Name{Structure_Name_Number} = nextline; %#ok<*AGROW>
        elseif strncmp(nextline,'Volume', 6)
            Volume{Structure_Name_Number} = nextline;
        elseif strncmp(nextline,'Dose Cover', 10)
            Dose_Cover{Structure_Name_Number} = nextline;
        elseif strncmp(nextline,'Sampling Cover', 14)
            Sampling_Cover{Structure_Name_Number} = nextline;
        elseif strncmp(nextline,'Min Dose', 8)
            Min_Dose{Structure_Name_Number} = nextline;
        elseif strncmp(nextline,'Max Dose', 8)
            Max_Dose{Structure_Name_Number} = nextline;
        elseif strncmp(nextline,'Mean Dose', 9)
            Mean_Dose{Structure_Name_Number} = nextline;
        elseif strncmp(nextline,'Modal Dose', 10)
            Modal_Dose{Structure_Name_Number} = nextline;
        elseif strncmp(nextline,'Median Dose', 11)
            Median_Dose{Structure_Name_Number} = nextline;
        elseif strncmp(nextline,'STD', 3)
            STD{Structure_Name_Number} = nextline;
        elseif strncmp(nextline,'Equiv. Sphere Diam', 18)
            Equi_Sphere_Diamr{Structure_Name_Number} = nextline;
        elseif strncmp(nextline,'Conformity Index', 16)
            Conformity_Index{Structure_Name_Number} = nextline;
        elseif strncmp(nextline,'Gradient Measure', 16)
            Gradient_Measure{Structure_Name_Number} = nextline ;
        elseif regexp(nextline,'Ratio of Total Structure Volume')
            % Your code wont work unless you have 'Ratio of Total Structure Volume'
            % in it RIGHT before the beginning of the numbers. Find something else
            % right before the beginning of the dvh otherwise.
            Structure_Name_Number=Structure_Name_Number+1;
            break
        end
        nextline = fgetl(fid); % get the line
    end
    
    while 1
        if ~regexp(nextline,'Structure:')
            break
        end
        nextline = fgetl(fid); % get the line
        if isempty(nextline)
            lineIndex = 1;
            if number_columns==2
                Whole_DVH(:,n+Organs:n+Organs+1) = [Variable_A; Variable_B]';
                n = n+1;
            elseif number_columns==3
                Whole_DVH(:,n+Organs:n+Organs+2) = [Variable_A; Variable_B ; Variable_C]';
                n=n+2;
            end
            Organs=Organs+1;
            clear Dose_cGy Relative_Dose
            break
        end
        cellArrayBlock = textscan(nextline,'%f',100,'Delimiter',',');
        
        if  size(cellArrayBlock{1},1)==2
            number_columns=2;
        elseif  size(cellArrayBlock{1},1)==3
            number_columns=3;
        end
        
        LineData = cellArrayBlock{:,1}';
        Size_Matrice = size(cellArrayBlock{1},1);
        if  Size_Matrice==2
            Variable_A(lineIndex) = LineData(1);
            Variable_B(lineIndex) = LineData(2);
        elseif  Size_Matrice==3
            Variable_A(lineIndex) = LineData(1);
            Variable_B(lineIndex) = LineData(2);
            Variable_C(lineIndex) = LineData(3);
        end
        
        lineIndex = lineIndex + 1;
    end
end
fclose(fid);
disp('Finish reading all the data!')

%% Get the actual data from the heades and removed the bits that are useless.
% If these data are numbers, cellfun turns them into matrice file that can
% be easily plotted.


a=0;
PrescribedDose = regexprep(PrescribedDose, 'Prescribed dose \[cGy]: ', '');
if(strcmp(PrescribedDose, 'not defined'))
    PrescribedDose = zeros(1, Structure_Name_Number);
else
    PrescribedDosea = cellfun(@str2num,PrescribedDose);
end




Structure_Name = regexprep(Structure_Name, 'Structure: ', '');

Volume = regexprep(Volume, 'Volume \[cm³]: ', '');
Volume=cellfun(@str2num,Volume);
Dose_Cover = regexprep(Dose_Cover, 'Dose Cover.\[%]: ', '');
Dose_Cover=cellfun(@str2num,Dose_Cover);

Sampling_Cover = regexprep(Sampling_Cover, 'Sampling Cover.\[%]: ', '');
Sampling_Cover=cellfun(@str2num,Sampling_Cover);

Min_Dose = regexprep(Min_Dose, 'Min Dose \[cGy]: ', '');
Min_Dose = regexp(Min_Dose,'\d+\.?\d*','match');
for u=1:size(Min_Dose ,2)
    % iterate over each of the 4 columns
    temp(u) = Min_Dose{u}(1,:);
    % do stuff with temp
end
Min_Dose = cellfun(@str2num, temp);

% Min_Dose=cellfun(@cell2mat, Min_Dose);
% try
%     aa=cellfun(@str2num,temp);
% catch
%     Min_Dose = zeros(1, size(Dose_Cover, 2))
% end
% Min_Dose=cellfun(@str2num,Min_Dose,'UniformOutput',false);

Max_Dose = regexprep(Max_Dose, 'Max Dose \[cGy]: ', '');
% Max_Dose=cellfun(@str2num,Max_Dose);
% Max_Dose_temp=cellfun(@str2num,Max_Dose,'UniformOutput',true);
Max_Dose = regexp(Max_Dose,'\d+\.?\d*','match');
for u=1:size(Max_Dose ,2)
    % iterate over each of the 4 columns
    temp(u) = Max_Dose{u}(1,:);
    % do stuff with temp
end
Max_Dose = cellfun(@str2num, temp);

Mean_Dose = regexprep(Mean_Dose, 'Mean Dose \[cGy]: ', '');
% Mean_Dose=cellfun(@str2num,Mean_Dose);
% Mean_Dose=cellfun(@str2num,Mean_Dose,'UniformOutput',false);
Mean_Dose  = regexp(Mean_Dose,'\d+\.?\d*','match');
for u=1:size(Mean_Dose ,2)
    % iterate over each of the 4 columns
    temp(u) = Mean_Dose{u}(1,:);
    % do stuff with temp
end
Mean_Dose = cellfun(@str2num, temp);


Modal_Dose = regexprep(Modal_Dose, 'Modal Dose \[cGy]: ', '');
% Modal_Dose=cellfun(@str2num,Modal_Dose);
% Modal_Dose=cellfun(@str2num,Modal_Dose,'UniformOutput',false);
Modal_Dose  = regexp(Modal_Dose,'\d+\.?\d*','match');
for u=1:size(Modal_Dose ,2)
    % iterate over each of the 4 columns
    temp(u) = Modal_Dose{u}(1,:);
    % do stuff with temp
end
Modal_Dose = cellfun(@str2num, temp);

Median_Dose = regexprep(Median_Dose, 'Median Dose \[cGy]: ', '');
% Median_Dose=cellfun(@str2num,Median_Dose);
% Median_Dose=cellfun(@str2num,Median_Dose,'UniformOutput',false);
Median_Dose = regexp(Median_Dose,'\d+\.?\d*','match');
for u=1:size(Median_Dose ,2)
    % iterate over each of the 4 columns
    temp(u) = Median_Dose{u}(1,:);
    % do stuff with temp
end
Median_Dose = cellfun(@str2num, temp);

STD = regexprep(STD, 'STD \[cGy]: ', '');
% STD=cellfun(@str2num,STD);
% STD=cellfun(@str2num,STD,'UniformOutput',false);
STD = regexp(STD,'\d+\.?\d*','match');
for u=1:size(STD ,2)
    % iterate over each of the 4 columns
    temp(u) = STD{u}(1,:);
    % do stuff with temp
end
STD = cellfun(@str2num, temp);

Equi_Sphere_Diamr = regexprep(Equi_Sphere_Diamr, 'Equiv. Sphere Diam. \[cm]: ', '');
Equi_Sphere_Diamr=cellfun(@str2num,Equi_Sphere_Diamr);

Conformity_Index = regexprep(Conformity_Index, 'Conformity Index: ', '');
%      Conformity_Index=cellfun(@str2num,Conformity_Index);
Conformity_Index = regexp(Conformity_Index,'\d+\.?\d*','match');
abc = Conformity_Index;

counter = 1
for u=1:size(abc ,2)
    % iterate over each of the 4 columns
    
    cellTemp = abc(u)
    try
        cellTempVal = cellTemp {1}{1}
        qq(u) = str2double(cellTempVal)
    catch
        qq(u) =0;
    end
end
Conformity_Index = qq;

Gradient_Measure = regexprep(Gradient_Measure, 'Gradient Measure \[cm]: ', '');
%   Gradient_Measure=cellfun(@str2num,Gradient_Measure);

%% Interest structures
% IST = {'BODY','B_Duodenum','B_Esophagus','B_Stomach','Heart','PGTV','RLV','TLV'};
% InterestOAR = {'BODY','B_Duodenum','B_Esophagus','B_Stomach','Heart','PGTV','TLV'};
% InterestOARForLegend = {'BODY','Duodenum','Esophagus','Stomach','Heart','PGTV','TLV'};
% V27	V30	V95	D2	D50	D98	Minimum dose	Maximum dose	Conformity index	Homogenity index


% InterestOAR = {'B_Duodenum','B_Esophagus','B_Stomach','Heart','PGTV','TLV'};
% InterestOARForLegend = {'Duodenum','Esophagus','Stomach','Heart','PGTV','TLV'};

InterestOAR = Structure_Name;
InterestOAR = transpose(InterestOAR);

[InterestOAR, indexTemp] = sortrows(InterestOAR);
InterestOAR = transpose(InterestOAR);

for iter3 = 1: size(InterestOAR , 2)
    str_temp = InterestOAR{iter3}
    splitedTemp = strsplit(str_temp, '_')
    InterestOARForLegend{iter3} = splitedTemp{end}
end
% InterestOARForLegend = cellfun(@str, '_')



colorMap = {[1 0 1], [1 1 0], [0 0 1], [0 1 1], [0 1 0], [1 0 0], [0 0 0], [0 0.4470, 0.7410], [0.33 0.7470, 0.4410]};

figure(hfigure_), hold on, grid on
% V27_Set = {}
% V30_Set = {}
for iter1= 1: size(InterestOAR, 2)
    IndexC = strfind(Structure_Name,InterestOAR{iter1});
    Index = find(not(cellfun('isempty',IndexC)));
    i= (3*Index)-3;
    xxx = Whole_DVH(:,i+1);
    yyy = Whole_DVH(:,i+Size_Matrice);
    
    xxx_absolute = Whole_DVH(:,i+2);
    [xData, yData] = prepareCurveData( xxx_absolute, yyy );
    
    % Set up fittype and options.
    ft = 'linearinterp';
    % Fit model to data.
    [fitresult, gof] = fit( xxx_absolute, yyy, ft, 'Normalize', 'on' );
    %     [fitresult_D, gof] = fit( yyy,xxx_absolute, ft, 'Normalize', 'on' );
    
    % old 
    %     V27 = fitresult(2700);
    %     V30 = fitresult(3000);
    %     V27_Set{indexTemp(iter1)} = V27;
    %     V30_Set{indexTemp(iter1)} = V30;
    
    % new 
    V5 =  fitresult(500);
    V10 =  fitresult(1000);
    V20=  fitresult(2000);
    V30=  fitresult(3000);
    V45=  fitresult(4500);
    V50=  fitresult(5000);
    V55=  fitresult(5500);
    V66=  fitresult(6600);
   
    V95 = fitresult(str2double(PrescribedDose{1}).*0.95);
    V100 = fitresult(str2double(PrescribedDose{1}).*1.0);
    
    V5_Set(indexTemp(iter1)) = V5;
    V10_Set(indexTemp(iter1)) = V10;
    V20_Set(indexTemp(iter1)) = V20;
    V30_Set(indexTemp(iter1)) = V30;
    V45_Set(indexTemp(iter1)) = V45;
    V50_Set(indexTemp(iter1)) = V50;
    V55_Set(indexTemp(iter1)) = V55;
    V66_Set(indexTemp(iter1)) = V66;
    
    V95_Set(indexTemp(iter1)) = V95;  % percent
    V100_Set(indexTemp(iter1)) = V100; % percent
    
    
    % Visualization
    stepSize = 17;
    plot(xxx(1:stepSize:end),yyy(1:stepSize:end) , marker_,'Color', colorMap{iter1} );
end

numStructure = size(Structure_Name, 2)
if strcmp(type_, 'equi')
    try
        currentString = hfigure_.CurrentAxes.Legend.String;
    catch
        legend(strcat(InterestOARForLegend, ' (equi)'))
    end
elseif strcmp(type_, 'planner')
    currentString = hfigure_.CurrentAxes.Legend.String;
    currentString(1, (numStructure*1)+1:numStructure*2) = strcat(InterestOARForLegend, ' (planner)');
    hfigure_.CurrentAxes.Legend.String=currentString ;
elseif strcmp(type_, 'predicted')
    currentString = hfigure_.CurrentAxes.Legend.String;
    currentString(1, (numStructure*2)+1:numStructure*3) = strcat(InterestOARForLegend, ' (predicted)');
    hfigure_.CurrentAxes.Legend.String=currentString ;
end

xlabel('Normalized dose [%]')
ylabel('Normalized volume [%]')

%% Plot here
%
% for i=0:Size_Matrice:(Organs-1)*Size_Matrice-Size_Matrice
%     hold on
%     xxx = Whole_DVH(:,i+1);
%     yyy = Whole_DVH(:,i+Size_Matrice);
%     stepSize = 17;
%     plot(xxx(1:stepSize:end),yyy(1:stepSize:end) , '--ks');
% end
% legend(strrep(Structure_Name,'B_', ''));
% xlabel('Normalized dose [%]')
% ylabel('Normalized Volume [%]')
% grid on
end