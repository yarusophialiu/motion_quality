classdef TrialRecording
    properties
        observer_id = '';
        trial = {};
        Samples = struct();  % not serialised
        Events = struct();
        Frames = struct();
        tau = 0;
    end
    
    methods

        function obj = initWithNode(obj, node)
            obj.observer_id = node.observerid;
            obj.trial = createTrialFromSerialisationNode(node.trial);
        end
        
        function node = serialiseToNode(obj, node)
            
        end
    end
end

