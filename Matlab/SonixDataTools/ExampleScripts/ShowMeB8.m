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
[Data, Header] = RPread('..\SampleData\Exam__Abdominal__C5-2slash60\Liver_BMode.b8', '6.0.3');

% Creating a new plot
hF = figure(1);
hA = axes;

% Plotting the first frame
plot_SonixRP(Data(:, :, 1), Header , [hA -1], 1);


