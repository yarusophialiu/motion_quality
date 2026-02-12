function plot_trial_path(trial)
    times = linspace(0, trial.duration, 10000);
    [xs, ys] = trial.get_target_location(times);
    plot(times, xs);
end