function cortical = pullFreeSurferCorticalDesikan(subs)
%% This function pulls values from freesurfer-outputed *h.aparc.stats files.
% (units is mm or mm^2) and saves the values as a labeled csv and as a .mat file.
% To use, simply enter your study-specific information below and run the function
% inthe command window:

studyName = ''; %Label for your dataset
studyfp = '/Applications/freesurfer/subjects/'; %SUBJECTS_DIR filepath
fsStatsDir = '/stats'; %path to stats directory within each subject folder
studyFolderPrefix = ''; %subject folder ID prefix if any (e.g. for folder MIG-2908, the prefix is 'MIG-')
studyFolderSuffix = ''; %subject folder ID suffix if any (e.g. for folder 196_T1, the suffix is '_T1')
outputDir = '/enter/path/here'; %where to save csv and mat file of results

% Then list the subject IDs you'd like to pull data from.
%subs = {'001','002'};

% Edit these to include more or fewer regions.  Defaults are usually pretty
% comprehensive for most data.
regionLabels ={'bankssts','caudalanteriorcingulate','caudalmiddlefrontal',...
    'cuneus','entorhinal','fusiform','inferiorparietal','inferiortemporal',...
    'isthmuscingulate','lateraloccipital','lateralorbitofrontal','lingual',...
    'medialorbitofrontal','middletemporal','parahippocampal','paracentral',...
    'parsopercularis','parsorbitalis','parstriangularis','pericalcarine',...
    'postcentral','posteriorcingulate','precentral','precuneus',...
    'rostralanteriorcingulate','rostralmiddlefrontal','superiorfrontal',...
    'superiorparietal','superiortemporal','supramarginal','frontalpole',...
    'temporalpole','transversetemporal','insula'};
whLabels = {'NumVert','WhiteSurfArea','MeanThickness'};

% Edit however you'd like the corresponding region labeled in your dataset
TableVarNames = horzcat({'subID'},regionLabels);

% Don't edit this. This is file and organization info.
hemiFile = {'lh.aparc.stats','rh.aparc.stats'};
hemiSide = {'left','right'};

%% Don't edit anything in this section unless you are more familiar with
% MATLAB.
[~,c] = size(subs);
[~,d] = size(regionLabels);
[~,g] = size(whLabels);
cortical.subjects = transpose(subs);
for hem = 1:2
    for j = 1:c
        %navigate to the freesurfer stats directory
        cd([ studyfp studyFolderPrefix subs{1,j} studyFolderSuffix fsStatsDir]);
        %Read in data from file
        [StructName,~,SurfArea,~,ThickAvg,ThickStd,~,~,~,~] = importFile(hemiFile{1,hem});
        e = size(StructName);
        %extract average cortical thickness
        for l = 1:d
            for i = 1:e
                if strcmp(regionLabels{1,l},StructName{i,1})
                    cortical.(hemiSide{1,hem}).thickavg(j,l) = ThickAvg(i,1);
                end
            end
            for i = 1:e
                if strcmp(regionLabels{1,l},StructName{i,1})
                    cortical.(hemiSide{1,hem}).thickstd(j,l) = ThickStd(i,1);
                end
            end
            for i = 1:e
                if strcmp(regionLabels{1,l},StructName{i,1})
                    cortical.(hemiSide{1,hem}).surfarea(j,l) = SurfArea(i,1);
                end
            end
        end
        
        % Extract whole hemisphere values
        [shortlabel,~,value] = importFile2(hemiFile{1,hem});
        e = size(shortlabel);
        for l = 1:g
            for i = 1:e
                if strcmp(whLabels{1,l},shortlabel{i,1})
                    cortical.(hemiSide{1,hem}).wholehemi(j,l) = value(i,1);
                end
            end
        end
    end
end
% Organize data into tables and write to csv.
cd(outputDir);
for hem = 1:2
    cortical.(hemiSide{1,hem}).ThickStdTbl = cell2table(horzcat(cortical.subjects,num2cell(cortical.(hemiSide{1,hem}).thickstd)));
    cortical.(hemiSide{1,hem}).ThickStdTbl.Properties.VariableNames = TableVarNames;
    writetable(cortical.(hemiSide{1,hem}).ThickStdTbl,[studyName hemiSide{1,hem} '_ThickSD_Desikan.csv'])
    
    cortical.(hemiSide{1,hem}).SurfAreaTbl = cell2table(horzcat(cortical.subjects,num2cell(cortical.(hemiSide{1,hem}).surfarea)));
    cortical.(hemiSide{1,hem}).SurfAreaTbl.Properties.VariableNames = TableVarNames;
    writetable(cortical.(hemiSide{1,hem}).SurfAreaTbl,[studyName hemiSide{1,hem} '_SurfArea_Desikan.csv'])
    
    cortical.(hemiSide{1,hem}).ThickAvgTbl = cell2table(horzcat(cortical.subjects,num2cell(cortical.(hemiSide{1,hem}).thickavg)));
    cortical.(hemiSide{1,hem}).ThickAvgTbl.Properties.VariableNames = TableVarNames;
    writetable(cortical.(hemiSide{1,hem}).ThickAvgTbl,[studyName hemiSide{1,hem} '_ThickAvg_Desikan.csv'])

    cortical.(hemiSide{1,hem}).WholeHemiTbl = cell2table(horzcat(cortical.subjects,num2cell(cortical.(hemiSide{1,hem}).wholehemi)));
    cortical.(hemiSide{1,hem}).WholeHemiTbl.Properties.VariableNames = whTableVarNames;  
    writetable(cortical.(hemiSide{1,hem}).WholeHemiTbl,[studyName hemiSide{1,hem} '_WholeHemi_Desikan.csv'])

end

end

function [StructName,NumVert,SurfArea,GrayVol,ThickAvg,ThickStd,meanCurv,GausCurv,FoldInd,CurvInd]=importFile(file)
%% Import data from text file.
% Script for importing data from the following text file:

%% Initialize variables.
delimiter = {'\t',' '};
startRow = 54;
formatSpec = '%s%f%f%f%f%f%f%f%f%f%*s%*s%*s%*s%*s%*s%[^\n\r]';

%% Open the text file.
fileID = fopen(file,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);

%% Allocate imported array to column variable names
StructName = dataArray{:, 1};
NumVert = dataArray{:, 2};
SurfArea = dataArray{:, 3};
GrayVol = dataArray{:, 4};
ThickAvg = dataArray{:, 5};
ThickStd = dataArray{:, 6};
meanCurv = dataArray{:, 7};
GausCurv = dataArray{:, 8};
FoldInd = dataArray{:, 9};
CurvInd = dataArray{:, 10};
end

function [shortlabel,longlabel,value] = importFile2(filename)

%% Initialize variables.
delimiter = ',';
startRow = 19;
endRow = 21;

%% Format string for each line of text:
formatSpec = '%*s%s%s%f%*s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.

dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Allocate imported array to column variable names
shortlabel = dataArray{:, 1};
longlabel = dataArray{:, 2};
value = dataArray{:, 3};

end