function stimuli = index_stimuli(stimuli)
%INDEX_STIMULI index the stimuli list
    for ii = 1:length(stimuli)
        stimuli(ii).id = ii - 1;
    end
end

