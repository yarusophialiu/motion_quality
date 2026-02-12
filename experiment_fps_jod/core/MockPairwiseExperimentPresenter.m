classdef MockPairwiseExperimentPresenter < IPairwiseExperimentPresenter
    %MockPairwiseExperimentPresenter for testing without a real pairwise
    %experiment presenter
       
    methods
        function result = compare_cross_stimuli(obj, refresh_rate_a, refresh_rate_b, stimulus_a, stimulus_b, index, fix_motion, bandwidth, LUT)
            flip = round(rand());  % should we swap "a" and "b"?
            if flip
                [refresh_rate_a, refresh_rate_b] = swap(refresh_rate_a, refresh_rate_b);
            end
            
            % some semi-consistent random respose
            if rand>normcdf(refresh_rate_b-refresh_rate_a, 0,8)
                result = 0;
            else
                result = 1;
            end
            
            if flip
                result = 1 - result;
            end  
        end
        
        function obj = experiment_finished(obj, force_kill)
        end
    end 
end

function [b, a] = swap(a, b)
end
