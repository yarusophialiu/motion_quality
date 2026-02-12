classdef Stimulus
    %STIMULUS object encapsulating a presentable stimulus
    
    properties
        class;  % what kind of stimulus is this?
        duration = 20.; % how long is the stimulus?
        motion = {};
        parameter = ''; % additional parameter7
        id = -1;
    end
    
    methods
        function node = serialiseToNode(obj, node)
            node.class = obj.class;
            node.duration = obj.duration;
            node.param = obj.parameter;
            node.motion = obj.motion.serialiseToNode(struct());
            node.id = obj.id;
        end
        
        function obj = initWithNode(obj, node)
            obj.class = node.class;
            obj.duration = node.duration;
            if isfield(node, 'param')
                obj.parameter = node.param;
            end
            if isfield(node, 'id')
                obj.id = node.id;
            end
            obj.motion = create_motion_from_node(node.motion);          
        end
    end
    
    properties(Constant)
        panorama_names = {'danube', 'kiralyret1', 'nhh', 'rysy1', 'stistvan', 'tata', 'tery'};
    end
    
    methods(Static)
        
        % factory methods for creating stimuli
        
        function obj = create_eyetracker_target_stimulus(motion, duration)
            if ~exist('duration', 'var') || isempty(duration)
                duration = 20;
            end
            obj = Stimulus();
            obj.class = 'ET_TARGET';
            obj.duration = duration;
            obj.motion = motion;
        end
        
        function obj = create_discs_stimulus(motion, duration)
            if ~exist('duration', 'var') || isempty(duration)
                duration = 20;
            end
            obj = Stimulus();
            obj.class = 'DISCS';
            obj.duration = duration;
            obj.motion = motion;
        end
        
        function obj = create_text_stimulus(motion, duration)
            if ~exist('duration', 'var') || isempty(duration)
                duration = 20;
            end
            obj = Stimulus();
            obj.class = 'TEXT';
            obj.duration = duration;
            obj.motion = motion;
        end
        
        function obj = create_panorama_stimulus(motion, panorama_name, duration)
            % panorama names should be one from the list of panorama_names
            if ~exist('duration', 'var') || isempty(duration)
                duration = 20;
            end
            obj = Stimulus();
            obj.class = 'PANORAMA';
            obj.duration = duration;
            obj.motion = motion;
            obj.parameter = panorama_name;
        end
    end
end

