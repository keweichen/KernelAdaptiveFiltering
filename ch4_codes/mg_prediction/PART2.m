%Copyright
%Weifeng Liu CNEL
%July 4 2008
%
%Description:
%Compare ALD, NC, ENC in KRLS using the m-g time series prediction
%
%Usage:
%Ch4, m-g time series, redundancy removal, figures

close all, clear all
clc

%% Data Formatting

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Data Formatting
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load MK30   %MK30 5000*1

varNoise = 0.001;
inputDimension = 7;

% Data size for training and testing
trainSize = 1000;
testSize = 100;

inputSignal = MK30 + sqrt(varNoise)*randn(size(MK30));
% inputSignal = inputSignal - mean(inputSignal);

%Input training signal with data embedding
trainInput = zeros(inputDimension,trainSize);
for k = 1:trainSize
    trainInput(:,k) = inputSignal(k:k+inputDimension-1);
end

%Input test data with embedding
testInput = zeros(inputDimension,testSize);
for k = 1:testSize
    testInput(:,k) = inputSignal(k+trainSize:k+inputDimension-1+trainSize);
end

% One step ahead prediction
predictionHorizon = 1;

% Desired training signal
trainTarget = zeros(trainSize,1);
for ii=1:trainSize
    trainTarget(ii) = inputSignal(ii+inputDimension+predictionHorizon-1);
end

% Desired training signal
testTarget = zeros(testSize,1);
for ii=1:testSize
    testTarget(ii) = inputSignal(ii+inputDimension+trainSize+predictionHorizon-1);
end


%Kernel parameters
typeKernel = 'Gauss';
paramKernel = 1;
%%


regularizationFactor = 0.001;
flagLearningCurve = 0;

length_nc = 20;
th_distance_nc_vector = linspace(0.05,0.2,length_nc);
th_error_nc_vector = linspace(0.05,0.2,length_nc);
mse_krls_nc = zeros(length_nc, length_nc);
distsize_krls_nc = zeros(length_nc, length_nc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%             KRLS NC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = 1:length_nc
    for kk = 1:length_nc
        th_distance_nc = th_distance_nc_vector(ii);
        th_error_nc = th_error_nc_vector(kk);

        [expansionCoefficient1,dictionaryIndex1,learningCurve1] = ...
            KRLS_NC(trainInput,trainTarget,testInput,testTarget,typeKernel,paramKernel,regularizationFactor,th_distance_nc,th_error_nc,flagLearningCurve);

        y_te = zeros(testSize,1);
        for jj = 1:testSize
            y_te(jj) = expansionCoefficient1*...
                ker_eval(testInput(:,jj),trainInput(:,dictionaryIndex1),typeKernel,paramKernel);
        end
        distsize_krls_nc(ii,kk) = length(dictionaryIndex1);
        mse_krls_nc(ii,kk) = mean((testTarget - y_te).^2);

    end
end


% =========end of KRLS_NC================




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%              KRLS ALD
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
length_ald = 100;
th_ald_vector = linspace(0.04,0.3,length_ald);
mse_krls_ald = zeros(length_ald, 1);
distsize_krls_ald = zeros(length_ald, 1);

for ii = 1:length_ald
    th_ald = th_ald_vector(ii);
    [expansionCoefficient2,dictionaryIndex2,learningCurve2] = ...
        KRLS_ALD(trainInput,trainTarget,testInput,testTarget,typeKernel,paramKernel,regularizationFactor,th_ald,flagLearningCurve);
    
    y_te = zeros(testSize,1);
    for jj = 1:testSize
        y_te(jj) = expansionCoefficient2*...
            ker_eval(testInput(:,jj),trainInput(:,dictionaryIndex2),typeKernel,paramKernel);
    end
    distsize_krls_ald(ii) = length(dictionaryIndex2);
    mse_krls_ald(ii) = mean((testTarget - y_te).^2);
end

% =========end of KRLS-ALD================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%             KRLS ENC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
length_enc = 20;
th_distance_enc_vector = linspace(0.04,0.2,length_enc);
th_error_enc_vector = linspace(0.05,0.2,length_enc);
mse_krls_enc = zeros(length_enc, length_enc);
distsize_krls_enc = zeros(length_enc, length_enc);

for ii = 1:length_enc
    for kk = 1:length_enc
        th_distance_enc = th_distance_enc_vector(ii);
        th_error_enc = th_error_enc_vector(kk);

        [expansionCoefficient3,dictionaryIndex3,learningCurve3] = ...
            KRLS_ENC(trainInput,trainTarget,testInput,testTarget,typeKernel,paramKernel,regularizationFactor,th_distance_enc,th_error_enc, flagLearningCurve);

        y_te = zeros(testSize,1);
        for jj = 1:testSize
            y_te(jj) = expansionCoefficient3*...
                ker_eval(testInput(:,jj),trainInput(:,dictionaryIndex3),typeKernel,paramKernel);
        end
        distsize_krls_enc(ii,kk) = length(dictionaryIndex3);
        mse_krls_enc(ii,kk) = mean((testTarget - y_te).^2);

    end
end
% =========end of KRLS_ENC================


% figure
% hold on
% for ii = 1:length_nc 
%     plot(distsize_krls_nc(:,ii),mse_krls_nc(:,ii), 'b*')
% end
% 
% figure
% plot(distsize_krls_ald,mse_krls_ald, 'b+')


figure
hold on
for ii = 1:length_nc 
    plot(distsize_krls_nc(:,ii),mse_krls_nc(:,ii), 'b*')
end
plot(distsize_krls_ald,mse_krls_ald, 'r+')

for ii = 1:length_enc 
    plot(distsize_krls_enc(:,ii),mse_krls_enc(:,ii), 'gd')
end

set(gca, 'FontSize', 14);
set(gca, 'FontName', 'Arial');
xlabel('network size'),ylabel('testing MSE')

