mat_all = load('/auto/homes/am2442/Documents/motion_quality/experiment_fps_jod/results/mat/mat_3_vel_all_obs.mat');
mat_first_two = load('/auto/homes/am2442/Documents/motion_quality/experiment_fps_jod/results/mat/mat_3_vel_am1.mat');
mat_all_sep = load('/auto/homes/am2442/Documents/motion_quality/experiment_fps_jod/results/mat/mat_all_obs.mat');

M_all = mat_all.M;
M_first_two = mat_first_two.M;
M = mat_all_sep.M;

M1 = squeeze(M(1,:,:));
M2 = squeeze(M(2,:,:));
M3 = squeeze(M(3,:,:));
M_all(1:24,1:24) = M1;
M_all(25:48,25:48) = M2;
M_all(49:72,49:72) = M3;
M_first_two(1:24,1:24) = M1;
M_first_two(25:48,25:48) = M2;
M_first_two(49:72,49:72) = M3;





q_all = pw_scale(M_all);
q_first_two = pw_scale(M_first_two);


plot(q_all(1:24)-q_all(25:48))
hold on
plot(q_all(25:48)-q_all(49:72))
hold on
plot(q_all(1:24)-q_all(49:72))
hold on
plot(q_first_two(1:24)-q_first_two(25:48))
hold on
plot(q_first_two(25:48)-q_first_two(49:72))
hold on
plot(q_first_two(1:24)-q_first_two(49:72))
legend({'1-2 all', '2-3 all', '1-3 all','1-2 first 2', '2-3 first 2', '1-3 first 2'})
ylabel('Difference')






