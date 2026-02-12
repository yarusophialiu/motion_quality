function [pairs] = select_comps_same_rr()

    % st1 st2 f1 f2 jod1 jod2
    pairs = [];
    ids = [1, 2, 6, 10, 14, 18, 22, 24];
    for ii = 1:2
        for jj = (ii+1):3
        for id = 1:numel(ids)
            pairs = [pairs; [ii,jj,ids(id),ids(id)]];
        end
        end
    end
end