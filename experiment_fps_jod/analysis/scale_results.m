d = load('results/mat/mat_all_obs');
M = d.M;

% load the potential stimuli
stimuli = load_stimuli_from_file('Initial');
refresh_rates = 50:5:165;

JODs = zeros(length(stimuli), length(refresh_rates));

% scale stimuli independently
% TODO: once we have cross-content comparisons, scale everything together
for ii=1:length(stimuli)
    fprintf(1, 'scaling stimulus %d\n', ii);
    JODs(ii,:) = pw_scale(squeeze(M(ii,:,:)))';
end

current_path = fileparts(mfilename('fullpath'));
save(sprintf('%s/scaled_results', current_path), 'M', 'JODs', 'stimuli', 'refresh_rates');

plot(refresh_rates, JODs');
legend(string(1:7));
