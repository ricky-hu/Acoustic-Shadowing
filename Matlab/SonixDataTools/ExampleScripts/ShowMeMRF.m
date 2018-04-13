% Clearing the environment
clc
clear
close all

% Making the other functions accessible to the environment
addpath('..\DataReaders\RPread');
addpath('..\ImageProcessing');
addpath('..\PlotFunctions');
addpath('..\Misc');

% Reading the data
[Data, Header] = RPread('..\SampleData\Exam__Abdominal__C5-2slash60\sampleM.mrf', '6.1.0');

% Creating a new plot
hF = figure(1);
hA = axes;

% Plotting the ensemble
for Cnt = 1:size(Data, 3)
    plot_SonixRP(Data(:, :, Cnt), Header , [hA hA], 0);
    pause(0.1)
end