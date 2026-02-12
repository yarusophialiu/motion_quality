function ss = get_validation1_ss(bandwidths, rrs)
%  3 bandwidths, 3 refresh rates, 3 scenes, 3 repetitions = 81
    
    ss= struct();
    
    % 3 bandwidths
    ss.bandwidths = bandwidths;
    
    % 3 refresh rates for each
    ss.bandwidths = repmat(1:3, 1, 3);
    ss.refresh_rates = rrs(:)';
    
    % 3 scenes
    ss.bandwidths = repmat(ss.bandwidths, 1, 3);
    ss.refresh_rates = repmat(ss.refresh_rates, 1, 3);
    ss.scenes = reshape(repmat(1:3, 9, 1), 1, 27);
    
    % 3 repetition
    ss.bandwidths = repmat(ss.bandwidths, 1, 3);
    ss.refresh_rates = repmat(ss.refresh_rates, 1, 3);
    ss.scenes = repmat(ss.scenes, 1, 3);
    ss.repetition = reshape(repmat(1:3, 27, 1), 1, 81);
    ss.id = 1:length(ss.repetition);
    
    % turn to array of structs
    ss = arrayfun(@(b,rr, s, r, id) struct('bandwidth', b, 'refresh_rate', rr, 'scene', s, 'repetition', r, 'id', id), ss.bandwidths', ss.refresh_rates', ss.scenes', ss.repetition', ss.id');
end

