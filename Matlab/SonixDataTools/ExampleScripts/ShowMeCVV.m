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
[Data, Header] = RPread('..\SampleData\Exam__Abdominal__C5-2slash60\Liver_ColorDopplerVelocityVariance.cvv', '6.0.3');

% Creating two new plots for velocity and variance
hF1 = figure(1);
hA1 = axes;
hF1 = figure(2);
hA2 = axes;

% Plotting the first frame
plot_SonixRP(Data(:, :, 1), Header , [hA1 hA2], 1);


