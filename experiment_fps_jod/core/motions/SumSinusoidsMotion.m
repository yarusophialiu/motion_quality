classdef SumSinusoidsMotion < IMotion
    %SumSinusoidsMotion irregular motion with potentially nonharmonic
    %sinusoids
    
    properties
        gain = 0.05;
        amplitudes = [2., 2., 2., 2., 2., 0.2, 0.2]';
        frequencies = [0.1, 0.14, 0.24, 0.41, 0.74, 1.28, 2.19]';
        phases = [0, 0, 0, 0, 0, 0, 0]';
    end
    
    methods
        
        function obj = randomise(obj)
            obj.phases = rand(size(obj.frequencies)) * pi * 2 - pi;
        end
        
        function [x,y] = get_target_location(obj, time)
            x = 0.5 + obj.gain * sum(obj.amplitudes .* sin(2 * pi * obj.frequencies * time + obj.phases));
            y = ones(size(x)) * 0.5;
        end
        
        function [vx, vy] = get_target_speed(obj, time)
            vx = obj.gain * sum(obj.amplitudes .* 2 .* pi .* obj.frequencies .* cos(2 * pi * obj.frequencies * time + obj.phases));
            vy = 0;
        end
        
        function [ax, ay] = get_target_acc(obj, time)
            ax = - obj.gain * sum(obj.amplitudes .* ((2 .* pi .* obj.frequencies) .^ 2) .* sin(2 * pi * obj.frequencies * time + obj.phases));
            ay = 0;
        end
        
        function node = serialiseToNode(obj, node)
            node = serialiseToNode@IMotion(obj, node);
            node.gain = obj.gain;
            node.frequencies = obj.frequencies;
            node.amplitudes = obj.amplitudes;
            node.phases = obj.phases;
        end
        
        function obj = initWithNode(obj, node)
            obj = initWithNode@IMotion(obj, node);
            obj.gain = node.gain;
            obj.frequencies = node.frequencies;
            obj.amplitudes = node.amplitudes;
            obj.phases = node.phases;
        end
    end
end

