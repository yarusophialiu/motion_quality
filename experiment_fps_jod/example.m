% load the potential stimuli
stimuli = load_stimuli_from_file('Example');

% create the experiment presenter
presenter = MockPairwiseExperimentPresenter();

array_of_frequencies = 50:5:165;
M = zeros(numel(array_of_frequencies));
% 10 trials

next_comp=[1,2];
budget_of_comparisons = 60;

columns_names = {'stimulus','frequency_1','frequency_2','chose_1','chose_2'};
table_res = cell2table(cell(0,numel(columns_names)),'VariableNames', columns_names);

active_stimulus = 1;

for ii = 1:budget_of_comparisons
    freq_1 = array_of_frequencies(next_comp(1));
    freq_2 = array_of_frequencies(next_comp(2));
    % request a comparison
    result = presenter.compare(freq_1, freq_2, stimuli(active_stimulus), ii);
    if result == -1
        % early exit
        warning('experiment interrupted');
        presenter.experiment_finished(true);
        return;
    end
    
    
    if result
        new_row = cell2table(cell({stimuli(active_stimulus).id,freq_1,freq_2,0,1}),'VariableNames', columns_names);
        M(next_comp(2),next_comp(1)) = M(next_comp(2),next_comp(1))+1;
    else
        new_row = cell2table(cell({stimuli(active_stimulus).id,freq_1,freq_2,1,0}),'VariableNames', columns_names);
        M(next_comp(1),next_comp(2)) = M(next_comp(1),next_comp(2))+1;
    end
    
    table_res = [table_res;new_row];
    writetable(table_res, 'results.csv');
    
    next_comp = get_next_comparison(M);
    
    % store experiment result
    
    fprintf(1, 'user picked %d\n', result);
end

% experiment finished gracefully
presenter.experiment_finished(false);