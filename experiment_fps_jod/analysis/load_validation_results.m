function Res = load_validation_results(observers, idx)
    if idx == 1
        idx = '';
    else
        idx = num2str(idx);
    end
    % load validation results
    current_path = fileparts(mfilename('fullpath'));
    filter = sprintf('%s/../results/csv/csv_val%s_*.csv', current_path, idx);
    rfiles = dir(filter);
    columns_names = {'exp_id','trial_id','stimulus','bandwidth','frequency','chose_1','chose_2'};
    Res = cell2table(cell(0,numel(columns_names)),'VariableNames', columns_names);
    
    for iF=1:length(rfiles)
         observer = regexp(rfiles(iF).name, 'csv_val\d*_(?<obs>.*)\.csv', 'tokens');
         observer = observer{1};
         if isempty(find(strcmp(observer, observers), 1))
             continue;
         end
         
         res = readtable(sprintf('%s/%s', rfiles(iF).folder, rfiles(iF).name));
         Res = [Res; res];
    end
end
