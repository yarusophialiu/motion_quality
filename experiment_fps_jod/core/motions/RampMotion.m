classdef RampMotion < IMotion
    %RampMotion starting after a random interval
    
    properties
        velocity = 1/3;
        delay = 2;
    end
    
    methods
        
        function obj = randomise(obj)
            obj.delay = 2.5 + rand() * 0.5;
        end
        
        function [x,y] = get_target_location(obj, time)
            x = 0.5 + max(0, (time - obj.delay)) * obj.velocity;
            y = 0.5;
        end
        
        function [vx, vy] = get_target_speed(obj, time)
            vy = 0;
            if time < obj.delay
                vx = 0;
            else
                vx = obj.velocity;
            end
        end
        
        function [ax, ay] = get_target_acc(obj, time)
            ax = 0;
            ay = 0;
        end
        
        function node = serialiseToNode(obj, node)
            node = serialiseToNode@IMotion(obj, node);
            node.v = obj.velocity;
            node.delay = obj.delay;
        end
        
        function obj = initWithNode(obj, node)
            obj = initWithNode@IMotion(obj, node);
            obj.velocity = node.v;
            obj.delay = node.delay;
        end
    end
end

