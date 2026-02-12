function [record_table, sessions] = load_results(trial_name, observer_ids, observer_sacc_th)
    % load_results loading results for given trial name and observer ids
    % observer_sacc_th: containers .Map that optionally maps observer_id to
    % a relative threshold. default = 1
    
    if ~exist('observer_sacc_th', 'var') || isempty(observer_sacc_th)
        observer_sacc_th = containers.Map();
    end

    % load and filter sessions
    path_dir = [fileparts(mfilename('fullpath')) '/../results'];
    sessions = readtable(sprintf('%s/sessions.csv', path_dir));
    sessions = sessions(strcmpi(sessions.trialName, trial_name), :);
    sessions.keep = zeros(size(sessions,1), 1);
    for io=1:length(observer_ids)
        matching_rows = strcmp(sessions.observerId, observer_ids{io});
        sessions(matching_rows,:).keep = sessions(matching_rows,:).keep + 1;
    end
    sessions = sessions(sessions.keep > 0, :);
    
    records = [];
    
    
    % load experiment recording files
    for is=1:size(sessions,1)
        recording_path = sprintf('%s/%d.json', path_dir, sessions.sessionId(is));
        if ~exist(recording_path, 'file')
            continue;
        end
        fprintf(1, 'processing %d.edf\n', sessions.sessionId(is));
        edf_path = sprintf('%s/%d.edf', path_dir, sessions.sessionId(is));
        edf_data = Edf2Mat(edf_path, 0);
        
        % we are guaranteed to have some valid experiment data now 
        recordings_text = fileread(recording_path);
        recordings_node = jsondecode(recordings_text);
        for ir=1:length(recordings_node.recordings)
            trial_recording = TrialRecording().initWithNode(recordings_node.recordings(ir));
            [samples, events, frames] = edf_filter(edf_data, trial_recording.trial);
            trial_recording.Samples = samples;
            trial_recording.Events = events;
            trial_recording.Frames = frames;
            sacc_th = 1;
            if isKey(observer_sacc_th, trial_recording.observer_id)
                sacc_th = observer_sacc_th(trial_recording.observer_id);
            end
            trial_recording = filter_sacc(trial_recording, sacc_th);
            records = [records; trial_recording];
        end
    end
    record_table = array2table(records, 'VariableNames',{'object'});
    record_table.observer_id = arrayfun(@(r)r.observer_id, record_table.object, 'UniformOutput', 0);
    record_table.trial_id = arrayfun(@(r)r.trial.id, record_table.object);
    record_table.refresh_rate = arrayfun(@(r)r.trial.refresh_rate, record_table.object);
    record_table.trial_name = arrayfun(@(r)class(r.trial), record_table.object, 'UniformOutput', 0);
end