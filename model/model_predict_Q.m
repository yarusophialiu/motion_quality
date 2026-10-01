function Q = model_predict_Q(refresh_rate_a, refresh_rate_b, v, predictable, resolution_reduction_a, resolution_reduction_b, params, part_mask, screen_width_px, fov, persistence, screen_width_px_b, fov_b, v_b)
    %model_predict_QP predict the quality difference between A and B in
    %JODs
    % +ve when A is better than B
    % part_mask = mask for model parts [QJ, QP, QO, pred] e.g. [1, 1, 1, 1]

    if ~exist('part_mask', 'var') || isempty(part_mask)
        part_mask = [1, 1, 1, 1];
    end
    
    if ~exist('screen_width_px', 'var') || isempty(screen_width_px)
        screen_width_px = 2560;
    end
    if ~exist('screen_width_px_b', 'var') || isempty(screen_width_px_b) 
        screen_width_px_b = screen_width_px;
    end
    if ~exist('fov', 'var') || isempty(fov)
        fov = 30;
    end
    if ~exist('fov_b', 'var') || isempty(fov_b)
        fov_b = fov;
    end
    if ~exist('persistence', 'var') || isempty(persistence)
        persistence = 1;
    end
    if ~exist('v_b', 'var') || isempty('v_b')
        v_b = v;
    end
    
    if sum(part_mask) == 0
        % nasty hack for simple log model
        Q = pmod_log(refresh_rate_a, params) - pmod_log(refresh_rate_b, params);
        
        if ~isreal(Q)
            Q = -1000;
        end
        return;
    end
    
    if ~part_mask(4)
        predictable = 1;
    end
    
    if predictable
        p = [0.001528, 0.072419, 1,1]; %1.309106 0.815505];
    else
        p = [0.004517, 0.160428, 1,1];%1.143048 0.707706];
    end

    
    omegas = [0.25, 0.5, 1, 2, 4, 8, 16, 32, 64];%2.^(0:6);
    csf = params(1) * csf_barten_2(omegas, 100);
    
    b_ra = sqrt(2) * fov / (screen_width_px * resolution_reduction_a);
    b_rb = sqrt(2) * fov_b / (screen_width_px_b * resolution_reduction_b);
    
    b_e = persistence * (p(1) * v + p(2));
    b_da = persistence * v / refresh_rate_a;
    b_db = persistence * v / refresh_rate_b;
    
    b_ma = weighted_conv(b_e, b_da, p(3:4));
    b_mb = weighted_conv(b_e, b_db, p(3:4));
    
    sig_a = sqrt(b_ma .^2 + b_ra .^2)/pi;
    sig_b = sqrt(b_mb .^2 + b_rb .^2)/pi;
           
    Q = 0;
    
    if part_mask(2)
        % parallel
        Q = Q + sig_to_Q(sig_a, sig_b, omegas, csf, params(5)) * params(2);
    end
    
    % Judder Quality
    if part_mask(1)
        Q = Q + params(3) * model_QJ(refresh_rate_a, refresh_rate_b, v, [], predictable);
    end
    
    % orthogonal quality
    sig_a = b_ra/pi;
    sig_b = b_rb/pi;
    if part_mask(3)
        Q = Q + sig_to_Q(sig_a, sig_b, omegas, csf, params(5)) * params(4);
    end
end

function Q = sig_to_Q(sig_a, sig_b, omegas, csf, beta)
    
    c_a = gaussian(omegas, 0, 1/(2*pi*sig_a), 1);
    c_b = gaussian(omegas, 0, 1/(2*pi*sig_b), 1);
    cn_ab = sum((c_a.* csf) .^ beta) - sum((c_b.* csf) .^ beta);
    Q = cn_ab;
    
end

function Q = model_QJ(rr_a, rr_b, v, params, pred)
    if ~exist('params', 'var') || isempty(params)
        %params = [0.0054,    2.0682];
        params = [0.004572222710067   0.006032124790787   2.574657335762098];
    end
    if v == 0
        v = 0.001;
    end
    
    beta = params(3);
    E_th_pred = 1/params(1);
    E_th_unpred = 1/params(2);
    
    rhos = [rr_a / v; rr_b / v];
    ss = [csf_spatiotemp_kelly(1:50, rr_a); csf_spatiotemp_kelly(1:50, rr_b)];
    peak_ss = max(ss, [], 2);
    min_rhos = [find(peak_ss(1) == ss(1,:), 1); find(peak_ss(2) == ss(2,:), 1)]; 
    rhos = max(min_rhos, rhos);
    E = [csf_spatiotemp_kelly(rhos(1), rr_a), ...
        max(csf_spatiotemp_kelly(rhos(2), rr_b))];
    
    if pred == 1
        E = E / E_th_pred;
    else
        E = E / E_th_unpred;
    end
    Q = (E(2)).^beta - (E(1)).^beta;
end

function V = weighted_conv(sig_a, sig_b, p)
    V = sqrt(p(1) * (sig_a) .^ 2 + p(2) * (sig_b) .^ 2);
end
