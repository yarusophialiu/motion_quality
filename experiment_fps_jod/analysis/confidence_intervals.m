addpath('for_confidence_intervals') 

load('scaled_results.mat')

matrices_fps = res.M;

scores = [];
stddev = [];
figure()

% compute confidence intervals for the given confidence level
confidence_level = 0.95;
confidence_interval_scale = fminsearch(@(x) (normcdf(x)-normcdf(-x) - confidence_level) .^ 2, 0.6745);

errors = zeros(2, size(matrices_fps, 1), size(matrices_fps, 2));

for ii = 1:size(matrices_fps,1)
    M_sc = squeeze(matrices_fps(ii,:,:));
    % q - scores, v - variance
    [q,v] = ts_M(M_sc);
    
    % standardise scores and variances and bring them to JOD by multiplying
    % with 1.4826
    qt = (q-mean(q))/std(q)*1.4826;
    qt = qt-qt(1);
    st = sqrt(v)/std(q)*1.4826;
    
    % save current fps
    scores = [scores;qt];
    stddev = [stddev;st];
    
    % scale with confidence interval
    high = confidence_interval_scale*st;
    low = confidence_interval_scale*st;  
    errors(1,ii,:) = low;
    errors(2,ii,:) = high;
    % plot the error bars
    errorbar([1:24],qt,low,high)
    hold on
end

save('errors_95', 'errors');

