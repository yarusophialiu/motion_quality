classdef StepsMotion < IMotion
    %StepsMotion smooth step motion (sin(x)+x)
    
    properties
        linear_velocity = 0.2;
        alternation_velocity = 0.4;
        direction = [1, 0];
    end
    
    methods
        
        function obj = randomise(obj)
            % noop
        end
        
        function [x,y] = get_target_location(obj, time)
            ta = obj.alternation_velocity;
            x = 0.5 + obj.direction(1) * obj.linear_velocity * (sin(time * ta * 2 * pi) / (2*pi*ta) + time);
            y = 0.5 + obj.direction(2) * obj.linear_velocity * (sin(time * ta * 2 * pi) / (2*pi*ta) + time);
        end
        
        function [vx, vy] = get_target_speed(obj, time)
            ta = obj.alternation_velocity;
            vx = obj.direction(1) * obj.linear_velocity * (cos(time * ta * 2 * pi) + 1);
            vy = obj.direction(2) * obj.linear_velocity * (cos(time * ta * 2 * pi) + 1);
        end
        
        function [ax, ay] = get_target_acc(obj, time)
            ta = obj.alternation_velocity;
            ax = - obj.direction(1) * obj.linear_velocity * 2 * pi * ta * sin(time * ta * 2 * pi);
            ay = - obj.direction(2) * obj.linear_velocity * 2 * pi * ta * sin(time * ta * 2 * pi);
        end
        
        function node = serialiseToNode(obj, node)
            node = serialiseToNode@IMotion(obj, node);
            node.va = obj.linear_velocity;
            node.ta = obj.alternation_velocity;
            node.dir_x = obj.direction(1);
            node.dir_y = obj.direction(2);
        end
        
        function obj = initWithNode(obj, node)
            obj = initWithNode@IMotion(obj, node);
            obj.linear_velocity = node.va;
            obj.alternation_velocity = node.ta;
            obj.direction = [node.dir_x, node.dir_y];
        end
    end
end

