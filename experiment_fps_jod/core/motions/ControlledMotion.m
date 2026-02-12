classdef ControlledMotion < IMotion
    %ControlledMotion motion controlled by the client mouse
    
    properties

    end
    
    methods
        
        function obj = randomise(obj)
            % noop
        end
        
        function [x,y] = get_target_location(obj, time)
            error('controlled motion has no known target location');
        end
        
        function [vx, vy] = get_target_speed(obj, time)
            error('controlled motion has no known target speed');
        end
        
        function [ax, ay] = get_target_acc(obj, time)
            error('controlled motion has no known target acceleration');
        end
        
        function node = serialiseToNode(obj, node)
            node = serialiseToNode@IMotion(obj, node);
        end
        
        function obj = initWithNode(obj, node)
            obj = initWithNode@IMotion(obj, node);
        end
    end
end

