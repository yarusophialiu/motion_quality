function stimuli = load_stimuli_from_file(name)
%LOAD_STIMULI_FROM_FILE Load a list of stimuli encoded as json from the
%specified location
    stimuli_nodes = jsondecode(fileread(sprintf('stimuli/%s.json', name)));
    stimuli(length(stimuli_nodes.stimuli), 1) =  Stimulus();
    for ii=length(stimuli_nodes.stimuli):-1:1
        stimuli(ii) = stimuli(ii).initWithNode(stimuli_nodes.stimuli(ii));
    end
end

