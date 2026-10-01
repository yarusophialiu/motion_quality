f = 0:0.05:120;

vs = linspace(0, 45, 4);
rrs = linspace(50, 165, 4);
ress = linspace(0.1, 1, 4);
close all
for iV=1:length(vs)
    v = vs(iV);
    figure('Name', sprintf('%0.0fdps', v));
    clf;
    ii = 0;
    for iRes=1:length(ress)
        res = ress(iRes);
        for iR=1:length(rrs)
            ii = ii + 1;
           
            rr = rrs(iR);
            v_b_e = f_box(f, 0.065+ 0.0019 * v);
            v_b_d = f_box(f, v / rr);
            v_b_res = f_tri(f, 30 / (2560 * res));
            v_b_m = v_b_e .* v_b_d .* v_b_res;
            sigma = mygaussianfit(f, v_b_m, 0.2);
            subplot(length(ress), length(rrs), ii);
            plot(f, v_b_m); hold on;
            plot(f, gaussian(f, 0, sigma, 1));
            xlim([0,60]);
            ylim([0, 1]);
            grid on;
            set(gca, 'XScale', 'log')
            title(sprintf('%0.0fHz  %0.0fx%0.0f', rr, 2560*res, 1440*res));
        end
    end 
end


