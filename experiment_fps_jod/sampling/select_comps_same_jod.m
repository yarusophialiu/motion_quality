function [pairs] = select_comps_same_jod()
    addpath('./sampling')
    all_res = load('./results/mat/mat_3_vel_all_obs.mat');
    sc = pw_scale(all_res.M);
    sc1 = sc(1:24);
    sc2 = sc(25:48);
    sc3 = sc(49:72);
    sc1(:,2) = 1;
    sc2(:,2) = 2;
    sc3(:,2) = 3;
    sc1(:,3) = [1:24]';
    sc2(:,3) = [1:24]';
    sc3(:,3) = [1:24]';

    allt = [sc1;sc2;sc3];
    
    allt = sortrows(allt,1);
    ii = 1;
    counter = 2;
    curr_id = 1;
    % st1 st2 f1 f2 jod1 jod2
    pairs = [];
    while ii<60 && counter<72
        
        if allt(counter,2) ~=  allt(curr_id,2)
            pairs = [pairs; [allt(curr_id,2),allt(counter,2),allt(curr_id,3),allt(counter,3), allt(curr_id,1),allt(counter,1)]];
            curr_id = counter;
            ii=ii+1;
        end
        counter = counter +1;
    end
end