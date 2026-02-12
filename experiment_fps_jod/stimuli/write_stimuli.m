function write_stimuli(stimuli, file_name)
%write_stimuli write a list of stimuli to file (as json)
    stimuliset = struct('stimuli', [], 'name', file_name);
   
    for ii = 1:length(stimuli)
        stimuliset.stimuli = [stimuliset.stimuli; stimuli(ii).serialiseToNode(struct())];
    end
       
    current_path = fileparts(mfilename('fullpath'));
    
    fid = fopen(sprintf('%s/%s.json', current_path, file_name), 'wt' );
    fprintf(fid, '%s', jsonencode(stimuliset));
    fclose(fid);
end

