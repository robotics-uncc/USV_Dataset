% A. Nikonowicz, A. Wolek,  UNC Charlotte, Aug. 2025
% MATLAB Script to generate plots from dataset.csv used in paper below.
%
% Toolboxes Required: "Image Processing Toolbox" (dependency of
% distinguishable_colors package)

% prepare workspace
clear; close all; clc;
set(groot, 'DefaultAxesFontName', 'Arial');
set(groot, 'DefaultTextFontName', 'Arial');
set(groot, 'DefaultUicontrolFontName', 'Arial'); % For UI controls
set(groot, 'DefaultUitableFontName', 'Arial');   % For UI tables

% load packages
addpath('distinguishable_colors/')
addpath('Violinplot-Matlab/')

% setup
color_dist = distinguishable_colors(6);
csvfile = 'dataset';
printFlag = 1; % flag (1 is on, 0 is off) to print plots to pdf

% read data
table = readtable(csvfile);

% UUV Bathymetry group 
for i = 1:1:height(table)
    UUV_weight = table.EmptyWeight_lbs_(i);
    UUV_endurance = table.Endurance_hr_(i);
    UUV_length = table.Length_ft_(i);
    if ( UUV_weight <= 30 )
        table.UUV_Weight_Group(i) = 1; % man portable
    elseif ( UUV_weight <= 60 )
        table.UUV_Weight_Group(i) = 2; % two-person
    elseif ( UUV_weight <= 500 )
        table.UUV_Weight_Group(i) = 3; % group 3
    elseif ( UUV_weight <= 2000 )
        table.UUV_Weight_Group(i) = 4; % group 4
    else 
        table.UUV_Weight_Group(i) = 5; % group 5
    end
end

% groups
counts_group(1) = sum(table.UUV_Weight_Group == 1);
counts_group(2) = sum(table.UUV_Weight_Group == 2);
counts_group(3) = sum(table.UUV_Weight_Group == 3);
counts_group(4) = sum(table.UUV_Weight_Group == 4);
counts_group(5) = sum(table.UUV_Weight_Group == 5);
groupNames = {'Group I','Group II','Group III','Group IV','Group V'};

figure;
figPosSize = [0.5 0.5 9 3.75];
figPaperSize = [9 3.75];
set(gcf,'Color','w')
set(gcf,'Units','inches')
set(gcf,'Position',figPosSize)
set(gcf,'PaperSize',figPaperSize)
subplot(1,2,1)
h = histogram('Categories',groupNames,'BinCounts',counts_group,'BarWidth', 0.5);
h.LineWidth = 1.5;
hAx = gca;
hAx.LineWidth = 1.5; % Adjust the value as needed
ylabel('Number of USVs')
grid on;
subplot(1,2,2)
h = histogram(table.EmptyWeight_lbs_,[0:100:6000]);
h.LineWidth = 1.5;
hAx = gca;
hAx.LineWidth = 1.5; % Adjust the value as needed
ylabel('Number of USVs')
xlabel('Weight (lbs)')
grid on;
xticks([0:1000:6000])
axis tight;

if ( printFlag )
    print(gcf,'-dpng','-r300','groups.png')
end

fprintf('Percentage below 500 lbs: %3.3f\n',sum(table.EmptyWeight_lbs_<=500)/length(table.EmptyWeight_lbs_))

% sort into groups
tableGroups{1} = table( table.UUV_Weight_Group == 1, : );
tableGroups{2} = table( table.UUV_Weight_Group == 2, : );
tableGroups{3} = table( table.UUV_Weight_Group == 3, : );
tableGroups{4} = table( table.UUV_Weight_Group == 4, : );
tableGroups{5} = table( table.UUV_Weight_Group == 5, : );

%% Hull Type

% groups
clear counts_group
counts_group(1) = sum(table.Hull == 1);
counts_group(2) = sum(table.Hull == 2);
counts_group(3) = sum(table.Hull == 3);

groupNames = {'Monohull','Catemaran','Trimaran'};
grid on;
figure;
figPosSize = [0.5 0.5 5 3.75];
figPaperSize = [5 3.75];
set(gcf,'Color','w')
set(gcf,'Units','inches')
set(gcf,'Position',figPosSize)
set(gcf,'PaperSize',figPaperSize)
h = histogram('Categories',groupNames,'BinCounts',counts_group,'BarWidth', 0.5);
h.LineWidth = 1.5;
hAx = gca;
hAx.LineWidth = 1.5; % Adjust the value as needed
ylabel('Number of USVs')
grid on;
if ( printFlag )
    print(gcf,'-dpng','-r300','hull.png')
end

%% Histogram of Countries
COG = table.CountryOfOrigin;
[uni,~,idx] = unique(COG);
for i = 1:1:max(idx)
    bins(i) = sum(idx==i);
end
% 
inds = (bins <= 2);
numOthers = sum(bins(inds));
fprintf('Percent Other: (%d/%d) = %3.3f\n',numOthers,sum(bins),numOthers/sum(bins)*100);

figure;
figPosSize = [0.5 0.5 10 3.75];
figPaperSize = [10 3.75];
set(gcf,'Color','w')
set(gcf,'Units','inches')
set(gcf,'Position',figPosSize)
set(gcf,'PaperSize',figPaperSize)
h = histogram('Categories',uni,'BinCounts',bins)
h.LineWidth = 1.5;
hAx = gca;
hAx.LineWidth = 1.5; % Adjust the value as needed

grid on;
set(gcf,'Color','w')
ylabel('Number of USVs')
for i =1:1:length(bins)
fprintf('%s : %d/%d (%3.3f ) \n',uni{i},bins(i),sum(bins),bins(i)/sum(bins)*100);
end

if ( printFlag )
    print(gcf,'-dpng','-r300','COG.png')
end


%% Speed Analysis

% sort into groups
tableTypes{1} = table( table.Hull == 1, : );
tableTypes{2} = table( table.Hull == 2, : );
tableTypes{3} = table( table.Hull == 3, : );

ms = 15;
scale = 1;
ytickvec = [1:1:15];
legendLoc = 'northeast';
figPosSize = [0.5 0.5 8 2.75];
figPaperSize = [8 2.75];
xlimVec = [0  500];
axPos1 = [0.75 0.5 3 2];
yval_label = 'Max. Speed (kts)';
yval = 'MaxSpeed_kt_';

figure;
subplot(1,2,1)
ylimvec = [min(ytickvec) max(ytickvec)];
set(gcf,'Units','inches')
grid on;
set(gcf,'Color','w')
set(gcf,'Color','w')
set(gcf,'Units','inches')
set(gcf,'Position',figPosSize)
set(gcf,'PaperSize',figPaperSize, 'Units', 'inches');
for i = 1:1:length(tableTypes)
     table = tableTypes{i};
     eval(['plot( table.EmptyWeight_lbs_,table.' yval ',''.'',''MarkerSize'',ms)']);
     hold on;
end
hAx = gca;
hAx.LineWidth = 1.5; % Adjust the value as needed
grid on;
xlabel('Weight (lbs)')
ylabel(yval_label)
yticks(ytickvec)
ylim(ylimvec)
xlim(xlimVec)
legend('Monohull','Catemaran','Trimaran','Location','north')



ytickvec = [1:1:15];
xlimVec = [500 4000];
subplot(1,2,2)
ylimvec = [min(ytickvec) max(ytickvec)];
set(gcf,'Units','inches')
grid on;
set(gcf,'Color','w')
set(gcf,'Color','w')
set(gcf,'Units','inches')
set(gcf,'Position',figPosSize)
set(gcf,'PaperSize',figPaperSize, 'Units', 'inches');
for i = 1:1:length(tableTypes)
     table = tableTypes{i};
     eval(['plot( table.EmptyWeight_lbs_,table.' yval ',''.'',''MarkerSize'',ms)']);
     hold on;
end
hAx = gca;
hAx.LineWidth = 1.5; % Adjust the value as needed
grid on;
xlabel('Weight (lbs)')
ylabel(yval_label)
yticks(ytickvec)
ylim(ylimvec)
xlim(xlimVec)
legend('Monohull','Catemaran','Trimaran','Location','north')
if ( printFlag )
    print(gcf,'-dpng','-r300','speed.png')
end

makeViolin;
if ( printFlag )
    print(gcf,'-dpng','-r300','speed_violin.png')
end

%% Footprint Analysis
ms = 15;
scale = 1;
ytickvec = [0:1:11];
legendLoc = 'northeast';
xlimVec = [0 500];
yval_label = 'Length (ft)';
yval = 'Length_ft_';
ylimvec = [min(ytickvec) max(ytickvec)];
figure;
subplot(1,2,1)
set(gcf,'Units','inches')
grid on;
set(gcf,'Color','w')
set(gcf,'Color','w')
set(gcf,'Units','inches')
set(gcf,'Position',figPosSize)
set(gcf,'PaperSize',figPaperSize, 'Units', 'inches');
for i = 1:1:length(tableTypes)
     table = tableTypes{i};
     eval(['plot( table.EmptyWeight_lbs_,table.' yval ',''.'',''MarkerSize'',ms)']);
     hold on;
end
hAx = gca;
hAx.LineWidth = 1.5; % Adjust the value as needed
grid on;
xlabel('Weight (lbs)')
ylabel(yval_label)
yticks(ytickvec)
ylim(ylimvec)
xlim(xlimVec)
legend('Monohull','Catemaran','Trimaran','Location','north')

ms = 15;
scale = 1;
ytickvec = [4:2:26];
legendLoc = 'northeast';
xlimVec = [500 4000];
yval_label = 'Length (ft)';
yval = 'Length_ft_';
ylimvec = [min(ytickvec) max(ytickvec)];

subplot(1,2,2)
set(gcf,'Units','inches')
grid on;
set(gcf,'Color','w')
set(gcf,'Color','w')
set(gcf,'Units','inches')
set(gcf,'Position',figPosSize)
set(gcf,'PaperSize',figPaperSize, 'Units', 'inches');
for i = 1:1:length(tableTypes)
     table = tableTypes{i};
     eval(['plot( table.EmptyWeight_lbs_,table.' yval ',''.'',''MarkerSize'',ms)']);
     hold on;
end
hAx = gca;
hAx.LineWidth = 1.5; % Adjust the value as needed
grid on;
xlabel('Weight (lbs)')
ylabel(yval_label)
yticks(ytickvec)
ylim(ylimvec)
xlim(xlimVec)
legend('Monohull','Catemaran','Trimaran','Location','north')

if ( printFlag )
    print(gcf,'-dpng','-r300','length.png')
end

ytickvec = [0:2:26];
makeViolin;
if ( printFlag )
    print(gcf,'-dpng','-r300','length_violin.png')
end

%% Endurance Analysis
ms = 15;
scale = 1;
ytickvec = [2:2:24];
legendLoc = 'northeast';
xlimVec = [0 500];
yval_label = 'Endurance (hrs)';
yval = 'Endurance_hr_';
ylimvec = [min(ytickvec) max(ytickvec)];

figure;
subplot(1,2,1)
set(gcf,'Units','inches')
grid on;
set(gcf,'Color','w')
set(gcf,'Color','w')
set(gcf,'Units','inches')
set(gcf,'Position',figPosSize)
set(gcf,'PaperSize',figPaperSize, 'Units', 'inches');
for i = 1:1:length(tableTypes)
     table = tableTypes{i};
     eval(['plot( table.EmptyWeight_lbs_,table.' yval ',''.'',''MarkerSize'',ms)']);
     hold on;
end
hAx = gca;
hAx.LineWidth = 1.5; % Adjust the value as needed
grid on;
xlabel('Weight (lbs)')
ylabel(yval_label)
yticks(ytickvec)
ylim(ylimvec)
xlim(xlimVec)
legend('Monohull','Catemaran','Trimaran','Location','north')

ms = 15;
scale = 1;
ytickvec = [0:24:240];
legendLoc = 'northeast';
xlimVec = [500 4000];
yval_label = 'Endurance (hrs)';
yval = 'Endurance_hr_';
ylimvec = [min(ytickvec) max(ytickvec)];

subplot(1,2,2)
set(gcf,'Units','inches')
grid on;
set(gcf,'Color','w')
set(gcf,'Color','w')
set(gcf,'Units','inches')
set(gcf,'Position',figPosSize)
set(gcf,'PaperSize',figPaperSize, 'Units', 'inches');
for i = 1:1:length(tableTypes)
     table = tableTypes{i};
     eval(['plot( table.EmptyWeight_lbs_,table.' yval ',''.'',''MarkerSize'',ms)']);
     hold on;
end
hAx = gca;
hAx.LineWidth = 1.5; % Adjust the value as needed
grid on;
xlabel('Weight (lbs)')
ylabel(yval_label)
yticks(ytickvec)
ylim(ylimvec)
xlim(xlimVec)
legend('Monohull','Catemaran','Trimaran','Location','north')
if ( printFlag )
    print(gcf,'-dpng','-r300','endurance.png')
end

ytickvec = [0:2:24];
makeViolin;
if ( printFlag )
    print(gcf,'-dpng','-r300','endurance_violin.png')
end