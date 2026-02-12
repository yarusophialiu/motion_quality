function [record_table, sessions] = load_results(trial_name, observer_ids)

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
        
        recordings_text = fileread(recording_path);
        recordings_node = jsondecode(recordings_text);
        for ir=1:length(recordings_node.recordings)
            trial_recording = recordings_node.recordings(ir);
            records = [records; trial_recording];
        end
    end
    record_table = array2table(records, 'VariableNames',{'object'});
    record_table.observer_id = arrayfun(@(r)r.observerid, record_table.object, 'UniformOutput', 0);
    record_table.trial_id = arrayfun(@(r)r.trial.id, record_table.object);
    record_table.scene = arrayfun(@(r)r.trial.conditions(1).scene, record_table.object, 'UniformOutput', 0);
    record_table.tech_a = arrayfun(@(r)r.trial.conditions(1).technique, record_table.object, 'UniformOutput', 0);
    record_table.tech_b = arrayfun(@(r)r.trial.conditions(2).technique, record_table.object, 'UniformOutput', 0);
    record_table.picked_name = arrayfun(@(r)r.trial.conditions(r.pickedConditionIndex+1).technique, record_table.object, 'UniformOutput', 0);
    record_table.picked_num = arrayfun(@(r)r.pickedConditionIndex, record_table.object);
    record_table.motion = arrayfun(@(r)r.trial.motion.class, record_table.object, 'UniformOutput', 0);
    record_table.refresh_rate = arrayfun(@(r)r.trial.refreshRate, record_table.object);
end