classdef IExperimentTrial
    properties
        refresh_rate = 60;
        duration = 10;
        id = -1;
    end
    
    methods
        function obj = IExperimentTrial(refresh_rate, duration)
            if ~exist('refresh_rate', 'var') || isempty(refresh_rate)
                refresh_rate = 60;
            end
            if ~exist('duration', 'var') || isempty(duration)
                duration = 10;
            end
            
            obj.refresh_rate = refresh_rate;
            obj.duration = duration;
        end
        
        function node = serialiseToNode(obj, node)
            node.refreshRate = obj.refresh_rate;
            node.duration = obj.duration;
            node.id = obj.id;
        end
        
        function obj = initWithNode(obj, node)
            obj.refresh_rate = node.refreshRate;
            obj.duration = node.duration;
            obj.id = node.id;
        end
        
        function obj = randomise(obj)
            % extend if you like...
        end
        
        function [v_mean, v_min, v_max] = get_velocity_stat(obj)
            v_mean = 0;
            v_min = inf;
            v_max = 0;
           
            times = linspace(0, obj.duration, 10000);
            [vxs,vys] = obj.get_target_speed(times);
            vs = sqrt(vxs .* vxs + vys .* vys);
            v_min = min(v_min, min(vs));
            v_max = max(v_max, max(vs));
            v_mean = v_mean + mean(vs);
        end
        
        function [locations, mins, maxs] = get_location_stat_rand(obj)
            rand_sample_count = 1000;
            locations = [0,0];
            mins = [inf, inf];
            maxs = [-inf, -inf];
            for ir=1:rand_sample_count
                sample_trial = obj.randomise();
                times = linspace(0, sample_trial.duration, 10000);
                [xs, ys] = sample_trial.get_target_location(times);
                locations = locations + [mean(xs), mean(ys)];
                mins = min(mins, min([xs; ys], [], 2)');
                maxs = max(maxs, max([xs; ys], [], 2)');
            end
            locations = locations / rand_sample_count;
        end
        
        function [v_mean, v_min, v_max] = get_velocity_stat_rand(obj)
            rand_sample_count = 1000;
            v_mean = 0;
            v_min = 10000;
            v_max = 0;
            for ir=1:rand_sample_count
                sample_trial = obj.randomise();
                times = linspace(0, sample_trial.duration, 1000);
                [vxs,vys] = sample_trial.get_target_speed(times);
                vs = sqrt(vxs .* vxs + vys .* vys);
                v_min = min(v_min, min(vs));
                v_max = max(v_max, max(vs));
                v_mean = v_mean + mean(vs);
            end
            v_mean = v_mean / rand_sample_count;
        end
        
        function plot_v_hist_rand(obj)
            rand_sample_count = 1000;
            t_sample_count = 1000;
            vs = zeros(1, rand_sample_count*t_sample_count);
            for ir=1:rand_sample_count
                sample_trial = obj.randomise();
                times = linspace(0, sample_trial.duration, 1000);
                [vxs,vys] = sample_trial.get_target_speed(times);
                vs(:,((ir-1) * t_sample_count + 1):((ir) * t_sample_count)) = sqrt(vxs .* vxs + vys .* vys);
            end    
            hist(vs);
        end
    end
    
    methods(Abstract)
        [x,y] = get_target_location(obj, time);
        [vx, vy] = get_target_speed(obj, time);
        [ax, ay] = get_target_acc(obj, time);
    end
end

