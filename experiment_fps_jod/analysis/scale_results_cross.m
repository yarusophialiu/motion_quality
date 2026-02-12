current_path = fileparts(mfilename('fullpath'));

% 3vel matrix
mat_file = load(sprintf('%s/../results/mat/mat_3_vel_all_obs.mat', current_path));
M = mat_file.M;

% single stimuli comparisons to update within-stimuli values
all_exp_mat = load(sprintf('%s/../results/mat/mat_all_obs.mat', current_path));
M_tmp = (all_exp_mat.M);
M1 = squeeze(M_tmp(1,:,:));
M2 = squeeze(M_tmp(2,:,:));
M3 = squeeze(M_tmp(3,:,:));
M(1:24,1:24) = M1;
M(25:48,25:48) = M2;
M(49:72,49:72) = M3;


a = pw_scale(M);
q1 = a(1:24);
q2 = a(25:48);
q3 = a(49:end);
figure
plot(q1)
hold on
plot(q2)
hold on
plot(q3)


res = load('scaled_results');
if isfield(res, 'res')
    res = res.res;
end

res.JODs3 = [q1'; q2'; q3'];
res.q2 = q2;
res.q3 = q3;

current_path = fileparts(mfilename('fullpath'));
save(sprintf('%s/scaled_results', current_path), 'res');