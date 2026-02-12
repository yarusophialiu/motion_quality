classdef SinusoidMotion < IMotion
    %SINUSOIDMOTION simple sinusoid motion
    
    properties
        amplitude = 0.4;
        frequency = 0.2;
        direction = [1, 0];
    end
    
    methods
        
        function obj = randomise(obj)
            % noop
        end
        
        function [x,y] = get_target_location(obj, time)
            x = 0.5 + obj.direction(1) * obj.amplitude * cos(2 * pi * time * obj.frequency);
            y = 0.5 + obj.direction(2) * obj.amplitude * cos(2 * pi * time * obj.frequency);
        end
        
        function [vx, vy] = get_target_speed(obj, time)
            vx = - obj.direction(1) * obj.amplitude * 2 * pi * obj.frequency * sin(2 * pi * time * obj.frequency);
            vy = - obj.direction(2) * obj.amplitude * 2 * pi * obj.frequency * sin(2 * pi * time * obj.frequency);
        end
        
        function [ax, ay] = get_target_acc(obj, time)
            ax = - obj.direction(1) * obj.amplitude * ((2 * pi * obj.frequency) .^ 2) * cos(2 * pi * time * obj.frequency);
            ay = - obj.direction(2) * obj.amplitude * ((2 * pi * obj.frequency) .^ 2) * cos(2 * pi * time * obj.frequency);
        end
        
        function node = serialiseToNode(obj, node)
            node = serialiseToNode@IMotion(obj, node);
            node.amplitude = obj.amplitude;
            node.frequency = obj.frequency;
            node.dir_x = obj.direction(1);
            node.dir_y = obj.direction(2);
        end
        
        function obj = initWithNode(obj, node)
            obj = initWithNode@IMotion(obj, node);
            obj.amplitude = node.amplitude;
            obj.frequency = node.frequency;
            obj.direction = [node.dir_x, node.dir_y];
        end
    end
end

