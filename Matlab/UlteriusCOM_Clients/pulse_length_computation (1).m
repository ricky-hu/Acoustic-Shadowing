%% Pulse lengths are defined empirically as the range of spatial lags (samples in the axial 
% direction) over which the two-sided correlation coefficient (linearly interpolated at 1/1000 
% of a sample to obtain fractional lags) remained above 0.2 level. 
% The example is for a demonstration purpose. For a single scatterer, 0.1
% level is found to be the empirical level to compute the pulse length.


%% Example for a single scatterer

load pulse_length

% example_signal represents the RF data when there is only a single scatterer present
num_sample = length(example_signal); 
depth = 30; %mm
figure, plot(example_signal),title('Example Signal') 

[corr_coeff,lag]=xcorr(example_signal,example_signal,'coeff'); 
corr_coeff_interp = interp(corr_coeff,10);  % interpolating to to get fractional lag if required
lag_interp = interp(lag,10); 
figure, plot(lag_interp,corr_coeff_interp), title('Correlation Curve')
hold on, plot(lag_interp, .1*ones(length(corr_coeff_interp),1) )
xlim([-50 50])
ylim ([-1.2 1.2])


pulse_length_example = lag_interp(max(find(corr_coeff_interp>.1))) - lag_interp(min(find(corr_coeff_interp>.1)));



% From the figure, the correlation coefficient curve remains above 0.1 from
% lag = -24.1 to lag = 24.1. The pulse length = 48.2, which is very close
% to actual pulse length 49 axial samples.

% convert pulse length from sample number to mm
pulse_length_example_mm =pulse_length_example*depth/num_sample;


%% Example for RF data from tissue


num_sample = length(Data);
window_size = 200;
num_lines = size(Data,2); 

% select the segment near the focal region from the central RF line
% you can adjust the range according to your focus information
% here we assume that focus is at the center 
X = Data(num_sample/2-window_size:num_sample/2+window_size,num_lines/2); 
figure, plot( X),title('Signal from Tissue' ) 

[corr_coeff_tissue,lag_tissue]=xcorr(X,X,'coeff'); 
corr_coeff_tissue_interp = interp(corr_coeff_tissue,10); 
lag_tissue_interp = interp(lag_tissue,10); 
figure, plot(lag_tissue_interp,corr_coeff_tissue_interp), title('Correlation Curve')
hold on, plot(lag_tissue_interp, .1*ones(length(corr_coeff_tissue_interp),1) )
xlim([-50 50])
ylim ([-1.2 1.2])

pulse_length_tissue = lag_tissue_interp(max(find(corr_coeff_tissue_interp>.1))) - lag_tissue_interp(min(find(corr_coeff_tissue_interp>.1)))
% lag = 85 axial samples


%% Test for 3_3MHz_curvilinear.rf 

% selecting the segment near the focal region from the central RF line
num_sample = length(RF_3_3MHz_curvilinear);
window_size = 200;
num_lines = size(RF_3_3MHz_curvilinear,2); 

% select the segment near the focal region from the central RF line
% you can adjust the range according to your focus information
% here we assume that focus is at the center 
X2 = RF_3_3MHz_curvilinear(round(num_sample/2)-window_size:round(num_sample/2)+window_size,num_lines/2); 
figure, plot( X2), title('Signal from 3_3MHz_curvilinear.rf' ) 

[corr_coeff_tissue2,lag_tissue2]=xcorr(X2,X2,'coeff'); 
corr_coeff_tissue_interp2 = interp(corr_coeff_tissue2,10); 
lag_tissue_interp2 = interp(lag_tissue2,10); 
figure, plot(lag_tissue_interp2,corr_coeff_tissue_interp2), title('Correlation Curve')
hold on, plot(lag_tissue_interp2, .1*ones(length(corr_coeff_tissue_interp2),1) )
xlim([-200 200])
ylim ([-1.2 1.2])

pulse_length_tissue2 = lag_tissue_interp2(max(find(corr_coeff_tissue_interp2>.1))) - lag_tissue_interp2(min(find(corr_coeff_tissue_interp2>.1)))
% lag = 85 axial samples

%%

%% Test for 4 MHz_curvilinear.rf 

% selecting the segment near the focal region from the central RF line
num_sample = length(RF_4MHz_curvilinear);
window_size = 200;
num_lines = size(RF_4MHz_curvilinear,2); 

% select the segment near the focal region from the central RF line
% you can adjust the range according to your focus information
% here we assume that focus is at the center 
X3 = RF_4MHz_curvilinear(num_sample/2-window_size:num_sample/2+window_size,num_lines/2); 
figure, plot( X3), title('Signal from 4MHz_curvilinear.rf' ) 

[corr_coeff_tissue3,lag_tissue3]=xcorr(X3,X3,'coeff'); 
corr_coeff_tissue_interp3 = interp(corr_coeff_tissue3,10); 
lag_tissue_interp3 = interp(lag_tissue3,10); 
figure, plot(lag_tissue_interp3,corr_coeff_tissue_interp3), title('Correlation Curve')
hold on, plot(lag_tissue_interp3, .1*ones(length(corr_coeff_tissue_interp3),1) )
xlim([-200 200])
ylim ([-1.2 1.2])

pulse_length_tissue3 = lag_tissue_interp3(max(find(corr_coeff_tissue_interp3>.1))) - lag_tissue_interp3(min(find(corr_coeff_tissue_interp3>.1)))




%%

%% Test for 5MHz_linear.rf 

% selecting the segment near the focal region from the central RF line
num_sample = length(RF_5MHz_linear);
window_size = 200;
num_lines = size(RF_5MHz_linear,2);

% select the segment near the focal region from the central RF line
% you can adjust the range according to your focus information
% here we assume that focus is at the center 
X4 = RF_5MHz_linear(round(num_sample/2)-window_size:round(num_sample/2)+window_size,num_lines/2); 
figure, plot( X4), title('Signal from 5MHz_linear.rf' ) 

[corr_coeff_tissue4,lag_tissue4]=xcorr(X4,X4,'coeff'); 
corr_coeff_tissue_interp4 = interp(corr_coeff_tissue4,10); 
lag_tissue_interp4 = interp(lag_tissue4,10); 
figure, plot(lag_tissue_interp4,corr_coeff_tissue_interp4), title('Correlation Curve')
hold on, plot(lag_tissue_interp4, .1*ones(length(corr_coeff_tissue_interp4),1) )
xlim([-200 200])
ylim ([-1.2 1.2])

pulse_length_tissue4 = lag_tissue_interp4(max(find(corr_coeff_tissue_interp4>.1))) - lag_tissue_interp4(min(find(corr_coeff_tissue_interp4>.1)))




%%

%% Test for 3_3MHz_curvilinear.rf 

% selecting the segment near the focal region from the central RF line
num_sample = length(RF_11MHz_linear);
window_size = 200;
num_lines = size(RF_11MHz_linear,2);

% select the segment near the focal region from the central RF line
% you can adjust the range according to your focus information
% here we assume that focus is at the center 
X5 = RF_11MHz_linear(num_sample/2-window_size:num_sample/2+window_size,num_lines/2); 
figure, plot( X5), title('Signal from 11MHz_linear.rf' ) 

[corr_coeff_tissue5,lag_tissue5]=xcorr(X5,X5,'coeff'); 
corr_coeff_tissue_interp5 = interp(corr_coeff_tissue5,10); 
lag_tissue_interp5 = interp(lag_tissue5,10); 
figure, plot(lag_tissue_interp5,corr_coeff_tissue_interp5), title('Correlation Curve')
hold on, plot(lag_tissue_interp5, .1*ones(length(corr_coeff_tissue_interp5),1) )
xlim([-200 200])
ylim ([-1.2 1.2])

pulse_length_tissue5 = lag_tissue_interp5(max(find(corr_coeff_tissue_interp5>.1))) - lag_tissue_interp5(min(find(corr_coeff_tissue_interp5>.1)))



