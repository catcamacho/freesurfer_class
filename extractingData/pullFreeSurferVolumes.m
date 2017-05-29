function pullFreeSurferVolumes
%% This function pulls volumes from freesurfer-outputed aseg.stats files.
% (units is mm^3) and saves the values as a labeled csv and as a .mat file. 
% To use, simply type pullFreeSurferVolumes into the MATLAB command window. 
% For studies other than MIG, you'll need to specify study-specifics in the 
% following variables:

studyName = 'FSclass_20170509'; %Label for your dataset
studyfp = '/Users/myelin/Desktop/FS_Class/5-3_subjDir/'; %SUBJECTS_DIR filepath
fsStatsDir = '/stats'; %path to stats directory within each subject folder
studyFolderPrefix = ''; %subject folder ID prefix if any (e.g. for folder MIG-2908, the prefix is 'MIG-')
studyFolderSuffix = ''; %subject folder ID suffix if any (e.g. for folder 196_T1, the suffix is '_T1')
outputDir = '/Users/myelin/Desktop/FS_Class/5-3_subjDir'; %where to save csv and mat file of results

% Then list the subject IDs you'd like to pull data from.
subs = {'Monica','Sophie','Meghan'};

% Edit these to include more or fewer regions.  Defaults are usually pretty
% comprehensive and reliable for most data.
regionLabels = {'Left-Thalamus-Proper','Left-Caudate','Left-Putamen','Left-Pallidum',...
    'Left-Hippocampus','Left-Amygdala','Left-Accumbens-area','Left-VentralDC',...
    'Right-Thalamus-Proper','Right-Caudate','Right-Putamen','Right-Pallidum',...
    'Right-Hippocampus','Right-Amygdala','Right-Accumbens-area','Right-VentralDC'};
wbLabels = {'TotalGrayVol','CorticalWhiteMatterVol','eTIV'};
TableVarNames = {'subID','LeftThalamusProper','LeftCaudate','LeftPutamen',...
    'LeftPallidum','LeftHippocampus','LeftAmygdala','LeftAccumbensarea',...
    'LeftVentralDC','RightThalamusProper','RightCaudate','RightPutamen',...
    'RightPallidum','RightHippocampus','RightAmygdala','RightAccumbensarea',...
    'RightVentralDC','totalGMvol','totalWMvol','eICV'};

%% Don't edit anything in this section unless you are more familiar with 
% MATLAB.
[~,c] = size(subs);
[~,d] = size(regionLabels);
[~,g] = size(wbLabels);

for j = 1:c
    %navigate to the freesurfer stats directory
    cd([ studyfp studyFolderPrefix subs{1,j} studyFolderSuffix fsStatsDir]);
    %Read in data from aseg.stats
    file = fopen('aseg.stats','r');
    A = textscan(file,'%f %f %f %f %s %f %f %f %f %f','CommentStyle','#','Delimiter',{'\t',' '},'MultipleDelimsAsOne',true);
    B = horzcat(array2table([A{1,1:4}],'VariableNames',{'Index','SegId','NVoxels','Volume_mm3'}),array2table(A{1,5},'VariableNames',{'StructName'}));
    [e,~] = size(B);
    %extract volumes for select subcortical structures
    for l = 1:d
        for i = 1:e
            if strcmp(regionLabels(1,l),table2cell(B(i,5)))
                temp(j,l) = table2cell(B(i,4));
            end
        end
    end
    %extract estimated total gray/white matter volume and estimated
    %intracranial volume from aseg.stats
    file = fopen('aseg.stats','r');
    C = textscan(file,'%s%s%s%f%s%[^\n\r]',21,'Delimiter',',','HeaderLines',13,'ReturnOnError',false);
    D = horzcat(array2table([C{1,2:3}],'VariableNames',{'shortlabel','description'}),array2table(C{1,4},'VariableNames',{'volume'}));
    fclose('all'); 
    [f,~] = size(D);
    for l = 1:g
        for i = 1:f
            if strcmp(wbLabels(1,l),table2cell(D(i,1)))
                temp2(j,l) = table2cell(D(i,3));
            end
        end
    end
end

%Combine data into one labeled table.
aseg = cell2table(transpose(subs));
aseg(:,2:d+1) = cell2table(temp);
aseg(:,d+2:d+1+g) = cell2table(temp2);
aseg.Properties.VariableNames = TableVarNames;

%create data struct to save as .mat file
data.aseg = aseg;
data.raw = table2array(aseg(:,2:d+1+g));
data.info.subs = table2cell(aseg(:,1));
data.info.rawLabels = TableVarNames;

%write table to files
cd(outputDir);
writetable(aseg,[studyName '_fsVolumes.csv'])
save([studyName '_fsVolumes.mat'],'data')
end

