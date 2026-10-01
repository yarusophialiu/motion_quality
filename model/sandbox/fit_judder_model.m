params = [0.005, 0.008, 1];
[fa, fb] = meshgrid(50:5:165);

Qs = [0.3333, 0.6190; 0.2381, 0.6190; 0.0476, 0.0476; 0, 0];
fs = [50; 60; 72; 165/2];

[params,e ] = fminsearch(@(p) model_err(p, fs, Qs), params)
figure(1);
subplot(1,2,1);
pred = arrayfun(@(fa,fb) model_QJ(fa, fb, params,0), fa, fb);
surf(fa, fb, pred );
hold on;
plot3(fs*2, fs, Qs(:,2), 'x', 'Color', 'red');
hold off;
zlim([-2, 2]);
title('unpred');


subplot(1,2,2);
pred = arrayfun(@(fa,fb) model_QJ(fa, fb, params,1), fa, fb);
surf(fa, fb, pred );
hold on;
plot3(fs*2, fs, Qs(:,1), 'x', 'Color', 'red');
hold off;
zlim([-2, 2]);
title('pred');



function e = model_err(params, fs, Qs)
    pred = arrayfun(@(f) model_QJ(2*f, f, params, 1), fs);
    unpred = arrayfun(@(f) model_QJ(2*f, f, params, 0), fs);
    e = sqrt(mean(mean(([pred - Qs(:,1), unpred - Qs(:,2)]).^2)));
end

function Q = model_QJ(rr_a, rr_b, params, pred)
    v = 25;

    rhos = [rr_a; rr_b] / v;
    ss = [csf_spatiotemp_kelly(1:50, rr_a); csf_spatiotemp_kelly(1:50, rr_b)];
    peak_ss = max(ss, [], 2);
    min_rhos = [find(peak_ss(1) == ss(1,:), 1); find(peak_ss(2) == ss(2,:), 1)]; 
    rhos = max(min_rhos, rhos);
    S = [csf_spatiotemp_kelly(rhos(1), rr_a), ...
        max(csf_spatiotemp_kelly(rhos(2), rr_b))];
    
    if pred == 1
        S = S * params(1);
    else
        S = S * params(2);
    end
    
    Q = S(2).^params(3) - S(1).^params(3); 
end