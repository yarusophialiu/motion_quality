function [Samples, Events, Frames] = edf_filter(obj, trial)
    Events = struct();
    
    v = sscanf(obj.Events.Messages.info{2}, 'DISPLAY_COORDS %d %d %d %d');
    width = v(3);
    height = v(4);
    
    start_time = obj.Events.Messages.time(find(strcmp(obj.Events.Messages.info, sprintf('TRIALID %d', trial.id)), 1));
    sync_time = obj.Events.Messages.time(find(obj.Events.Messages.time > start_time & strcmp(obj.Events.Messages.info, 'SYNCTIME'), 1));
    end_time = obj.Events.Messages.time(find(obj.Events.Messages.time > sync_time & strcmp(obj.Events.Messages.info, 'TRIAL OK'), 1));
    
    trial_syncs = find(strcmp(obj.Events.Messages.info, 'SYNCTIME'));
    trial_idx = find(obj.Events.Messages.time(trial_syncs) == sync_time, 1);
    
    sample_idcs = (obj.Samples.time >= sync_time) & (obj.Samples.time <= end_time);
    Samples = copy_fields(obj.Samples,  sample_idcs, 1);
    
    if length(Samples.time) == 0
        error('invalid trial with id %d', trial.id);
    end
    
    
    ev_msg_idcs = (obj.Events.Messages.time >= sync_time) & (obj.Events.Messages.time <= end_time);
    Events.Messages.time = obj.Events.Messages.time(ev_msg_idcs);
    Events.Messages.info = obj.Events.Messages.info(ev_msg_idcs);
    %Events.Start.time = obj.Events.Start.time(trial_idx);
    %Events.Start.eye = obj.Events.Start.eye{trial_idx};
    %Events.Start.info = obj.Events.Start.info{trial_idx};
    %Events.pupilInfo = obj.Events.pupilInfo{trial_idx};
    
    ev_fix_idcs = find((obj.Events.Efix.start >= sync_time) & (obj.Events.Efix.end <= end_time));
    Events.fix = copy_fields(obj.Events.Efix, ev_fix_idcs, 2);
    
    ev_sacc_idcs = find((obj.Events.Esacc.start >= sync_time) & (obj.Events.Esacc.end <= end_time));
    Events.sacc = copy_fields(obj.Events.Esacc, ev_sacc_idcs, 2);
    
    ev_blink_idcs = find((obj.Events.Eblink.start >= sync_time) & (obj.Events.Eblink.start <= end_time));
    Events.blink = copy_fields(obj.Events.Eblink, ev_blink_idcs, 2);
    Events.End = obj.Events.End;
    %Events.End.time = Events.End.time(trial_idx);
    
    Frames = struct();
    frame_idcs = find(startsWith(Events.Messages.info, 'TARGETLOC'));
    Frames.time = Events.Messages.time(frame_idcs);
    Frames.idx = zeros(1, size(Frames.time, 2));
    Frames.x = zeros(1, size(Frames.time, 2));
    Frames.y = zeros(1, size(Frames.time, 2));
    for iF=1:length(Frames.idx)
        v = sscanf(Events.Messages.info{frame_idcs(iF)}, 'TARGETLOC %d %d %d');
        Frames.idx(iF) = v(1);
        Frames.x(iF) = v(2);
        Frames.y(iF) = v(3);
    end
    fprintf(1, '%d\n', trial.id);
    zdeltas = find(diff(Frames.time) == 0);
    for ii = 1:length(zdeltas)
         Frames.time(zdeltas(ii) + 1) = Frames.time(zdeltas(ii)) + 0.5;
    end
    
    Samples.target_disp_x = interp1(Frames.time, Frames.x, Samples.time, 'previous');
    Samples.target_disp_y = interp1(Frames.time, Frames.y, Samples.time, 'previous');
    
    cont_offset = sync_time + 500 / trial.refresh_rate;
    [tt_x, tt_y] = trial.get_target_location((Samples.time' - cont_offset) / 1000);
    Samples.target_cont_x = tt_x' * width;
    Samples.target_cont_y = tt_y' * height;
    
    [tv_x, tv_y] = trial.get_target_speed((Samples.time' - cont_offset) / 1000);
    Samples.target_cont_vx = tv_x' * width;
    Samples.target_cont_vy = tv_y' * height;
    
    [ta_x, ta_y] = trial.get_target_acc((Samples.time' - cont_offset) / 1000);
    Samples.target_cont_ax = ta_x' * width;
    Samples.target_cont_ay = ta_y' * height;    
    
    vs = diff(Samples.posX) ./ diff(Samples.time) * 1000;
    Samples.velX = 0.5 * ([nan; vs] + [vs; nan]);
    as = diff(Samples.velX) ./ diff(Samples.time) * 1000;
    Samples.accX = 0.5 * ([nan; as] + [as; nan]);
end

function dict = copy_fields(object, idcs, dimension)
    dict = struct();
    field_names = fieldnames(object);
    for iF=1:length(field_names)
        if dimension == 1
            dict.(field_names{iF}) = object.(field_names{iF})(idcs,:);
        else
            dict.(field_names{iF}) = object.(field_names{iF})(:,idcs);
        end
    end
        
end