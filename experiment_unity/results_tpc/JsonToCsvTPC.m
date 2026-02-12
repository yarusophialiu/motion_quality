
csv_data = readtable('dataTPC.csv');

filename = 'ExperimentTPC2_rkm38.json';
cls = jsondecode(fileread(filename));

exp_params = split(filename,["_","."]);
observer_id = char(exp_params(end-1));
exp_config = char(exp_params(1));

for i=1:length(cls.AllTrials)
    if(cls.AllTrials(i).isCompleted == 0)
        continue;
    end
    s.observer_id = observer_id;
    s.exp_config = exp_config;
    switch cls.AllTrials(i).sceneType
        case 0
            s.scene = "FPS";
        case 1
            s.scene = "RTS";
    end
    s.bandwith_condition1 = cls.AllTrials(i).Bandwidth_scene1;
    s.refresh_rate_condtion1 = cls.AllTrials(i).targetRefreshRate_scene1;
    s.bandwith_condition2 = cls.AllTrials(i).Bandwidth_scene2;
    s.refresh_rate_condtion2 = cls.AllTrials(i).targetRefreshRate_scene2;
    s.user_selection = cls.AllTrials(i).userSelection;
    csv_data = [csv_data;struct2table(s)];
end

writetable(csv_data,'dataTPC.csv');