% load the potential stimuli
stimuli = load_stimuli_from_file('Initial');

% create the experiment presenter
presenter = NetworkedPairwiseExperimentPresenter();


% 10 trials
for ii = 0:10

    % request a comparison
    stimulus = stimuli(randi(length(stimuli)));
    fa = rand()*60+100;
    fb = rand()*60+100;
    fprintf(1, 'checking stimulus id %d on %fHz and %fHz ... ', stimulus.id, fa, fb);
    pause(3);
    result = presenter.compare(fa, fb, stimulus, ii + 1);
    if result == -1
        % early exit
        warning('experiment interrupted');
        presenter.experiment_finished(true);
        return;
    end

    % store experiment result
    fprintf(1, 'user picked %d\n', result);
end

% experiment finished gracefully
presenter.experiment_finished(false);