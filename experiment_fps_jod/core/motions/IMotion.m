classdef IMotion
    %IMOTION Interface for any kind of motion
    
    properties
        
    end
    
    methods
        function node = serialiseToNode(obj, node)
            node.class = class(obj);
        end
        
        function obj = initWithNode(obj, node)
            % noop
        end
        
        function [v_mean, v_min, v_max] = get_velocity_stat_rand(obj)
            % get velocity statistics with randomisation
            rand_sample_count = 1000;
            v_mean = 0;
            v_min = 10000;
            v_max = 0;
            for ir=1:rand_sample_count
                sample_trial = obj.randomise();
                times = linspace(0, 20, 1000);
                [vxs,vys] = sample_trial.get_target_speed(times);
                vs = sqrt(vxs .* vxs + vys .* vys);
                v_min = min(v_min, min(vs));
                v_max = max(v_max, max(vs));
                v_mean = v_mean + mean(vs);
            end
            v_mean = v_mean / rand_sample_count;
        end
    end
    
    methods(Abstract)
        [x,y] = get_target_location(obj, time);
        [vx, vy] = get_target_speed(obj, time);
        [ax, ay] = get_target_acc(obj, time);
        
        obj = randomise(obj);
    end
end

