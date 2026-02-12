function [obj] = filter_sacc(obj, sacc_th)

    px_to_deg = 43.6/2560;

    t = obj.Samples.time;
    v = obj.Samples.velX;
    a = obj.Samples.accX;
    x = obj.Samples.posX;
    tx = obj.Samples.target_cont_x;
    tv = obj.Samples.target_cont_vx;
    ta = obj.Samples.target_cont_ax;
    
    blink_mask = zeros(size(t));
    
    % delete +-150ms region around blink
    for iB=1:length(obj.Events.blink.eye)
        blink_mask((t > obj.Events.blink.start(iB) - 150) & (t < obj.Events.blink.end(iB) + 150)) = 1;
    end
    
    saccade_mask = blink_mask;
    saccade_mask(t < (t(1) + 800)) = 1;
    saccade_mask((abs(v - tv) * px_to_deg > 25 * sacc_th) | (abs(a - ta) * px_to_deg > 9000 * sacc_th)) = 1;
    
    % filter 1 0 1 changes
    saccade_mask(strfind(saccade_mask', [1,0,1])+1) = 1;
    saccade_mask(strfind(saccade_mask', [0,1,0])+1) = 0;
    oozzoo = strfind(saccade_mask', [1,1,0,0,1,1])+2;
    saccade_mask(oozzoo) = 1;
    saccade_mask(oozzoo+1) = 1;
    
    micro_sacc_count = sum([0; diff(saccade_mask) == 1]);
    obj.Events.sacc_count = micro_sacc_count - length(obj.Events.blink.eye);
    obj.Samples.mask = 1 - saccade_mask;

    valid_pos = logical(1-saccade_mask);
    obj.Samples.posXf = interp1(t(valid_pos), x(valid_pos), t);
    
    
    v2 = v;
    v2(~valid_pos) = nan;
    taus = -150:150;
    corrs = zeros(size(taus));
    for it = 1:length(taus)
        corrs(it) = corr(circshift(v2, -taus(it)), tv, 'Rows', 'complete');
    end
    [~, max_loc] = max(corrs);
    obj.tau = taus(max_loc) / 500;
end

