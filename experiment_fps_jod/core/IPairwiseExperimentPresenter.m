classdef IPairwiseExperimentPresenter
    %IPairwiseExperimentPresenter interface for presenting pairwise
    %experiment stimuli for motion quality experiments
    
    properties
        
    end
    
    methods
        function obj = IPairwiseExperimentPresenter()
        end
        
        % compare two refresh rates for a given stimulus.
        % stimulus should be an object of class Stimulus
        % index: how many stimuli have we done already?
        % result = 0 when "a" is picked
        %          1 when "b" is piked
        %          -1 when experiment got interrupted
        % [bandwidth]: the amount of bandwidth available in Pixels per
        % seconds (e.g. 248832000 for 1920x1080x120) default: -1 (no limit)
        % refresh_rate_a, refresh_rate_b: the refresh rates to compare.
        %       -1: use adaptive refresh rate (our technique)
        % [LUT]: lookup table (list of refresh rates for integer
        % velocities)
        function result = compare(obj, refresh_rate_a, refresh_rate_b, stimulus, index, bandwidth, LUT)
            if ~exist('LUT', 'var')
                LUT = [];
            end
            if ~exist('bandwidth', 'var')
                bandwidth = [];
            end
            
            result = obj.compare_cross_stimuli(refresh_rate_a, refresh_rate_b, stimulus, stimulus, index, 1, bandwidth, LUT);
        end
    end
    
    methods (Abstract)
        
        
        % compare two refresh rates and two given stimuli.
        % stimuli should be objects of class Stimulus
        % index: how many stimuli have we done already?
        % result = 0 when "a" is picked
        %          1 when "b" is piked
        %          -1 when experiment got interrupted
        % [fix_motion]: should the two stimuli motion be synchronised?
        % [bandwidth]: the 
        result = compare_cross_stimuli(obj, refresh_rate_a, refresh_rate_b, stimulus_a, stimulus_b, index, fix_motion, bandwidth, LUT)
        
        % notify the client that the experiment has been terminated
        % force_kill: should the clients be killed, or just display a
        % friendly message
        obj = experiment_finished(obj, force_kill)
    end 
end

