classdef TrialSet
    properties
        trials = {};
        name = '';
    end
    
    methods
        function obj = TrialSet()
            
        end
               
        function obj = initWithNode(obj, node)
            obj.name = node.name;
            obj.trials = {};
            for tid=1:length(node.trials)
                trial = createTrialFromSerialisationNode(node.trials{tid});
                obj.trials{tid} = trial;
            end
        end
        
        function node = serialiseToNode(obj, node)
            
        end
    end
end

