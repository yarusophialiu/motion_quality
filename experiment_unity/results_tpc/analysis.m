csv_data = readtable('dataTPC.csv');

observers = unique(csv_data.observer_id);
scenes = unique(csv_data.scene);

for k = 1:length(observers)
    odata = csv_data(strcmp(csv_data.observer_id, observers(k)),:);
    fprintf("\nObserver: " + observers(k));
    for j = 1: length(scenes)
        fprintf("\nScene: " + scenes(j));
        data = odata(strcmp(odata.scene, scenes(j)),:);
        total = [0 0 0];
        selected = [0 0 0];
        for i = 1:height(data)
            row = data(i,:);
            if(data.refresh_rate_condtion1(i) == 30  || data.refresh_rate_condtion2(i) == 30 )
                total(1) = total(1) + 1;
            elseif(data.refresh_rate_condtion1(i) == 60  || data.refresh_rate_condtion2(i) == 60 )
                total(2) = total(2) + 1;
            elseif(data.refresh_rate_condtion1(i) == 120  || data.refresh_rate_condtion2(i) == 120 )
                total(3) = total(3) + 1;
            end
            if((data.refresh_rate_condtion1(i) == 30 && data.user_selection(i) == 1) || (data.refresh_rate_condtion2(i) == 30 && data.user_selection(i) == 2))
                selected(1) = selected(1) + 1;
            elseif ((data.refresh_rate_condtion1(i) == 60 && data.user_selection(i) == 1) || (data.refresh_rate_condtion2(i) == 60 && data.user_selection(i) == 2))
                selected(2) = selected(2) + 1;
            elseif ((data.refresh_rate_condtion1(i) == 120 && data.user_selection(i) == 1) || (data.refresh_rate_condtion2(i) == 120 && data.user_selection(i) == 2))
                selected(3) = selected(3) + 1;
            end
        end
        fprintf("\n%% Chosen (30 60 120) = ");
        ratios = selected ./ total * 100
        if j==1
            fprintf("******************************\n");
        end
    end
    fprintf("-----------------------------------------------------------------------\n");
end
