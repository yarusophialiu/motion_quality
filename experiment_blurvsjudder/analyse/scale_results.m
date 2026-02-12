function scaled = scale_results(results, filter_fun, cache_name)
    current_dir = fileparts(mfilename('fullpath'));
    cache_file = sprintf('%s/../data/%s_scaled.mat', current_dir, cache_name);
    if exist(cache_file, 'file')
        data = load(cache_file);
        scaled = data.scaled;
        return;
    end
    
    bootstrap_samples = 500;
    
    results_filtered = results(find(arrayfun(filter_fun, table2struct(results))), :);
    result_refr = grpstats(results_filtered, {'refresh_rate', 'tech_a', 'tech_b', 'observer_id'}, { 'sum', 'mean', 'std',}, 'DataVars', {'picked_num'});
    
    techs = unique( cat( 1, result_refr.tech_a, result_refr.tech_b ) ); % all techniques
    techs = [techs(strcmp(techs, 'halfrr')); techs(~strcmp(techs, 'halfrr'))];
    techs = techs(1:2);
    
    stat_arr = [];
    
    refresh_rates = unique(result_refr.refresh_rate);
    N = length(techs);
    for iRR=1:length(refresh_rates)
        Ds = result_refr(result_refr.refresh_rate == refresh_rates(iRR), :);
        observers = unique(Ds.observer_id);
        jod = zeros( N, 1 );
        MM = zeros(length(observers), N*N);
        MS = zeros(N,N);
        for iO=1:length(observers)
            Dso = Ds(strcmp( Ds.observer_id, observers{iO} ), :);
            M = zeros(N,N);
            for kk=1:size(Dso, 1)

                % Find the indexes of both conditions
                c1 = find( strcmp( Dso.tech_a(kk), techs ), 1 );
                c2 = find( strcmp( Dso.tech_b(kk), techs ), 1 );

                if( isempty( c1 ) )
                   % error( 'Cannot find condition %s', Dso.condition_1(kk) );
                end
                if( isempty( c2 ) )
                  %  error( 'Cannot find condition %s', Dso.condition_2(kk) );
                end

                M(c2,c1) = M(c2,c1) + Dso.sum_picked_num(kk);
                M(c1,c2) = M(c1,c2) + (Dso.GroupCount(kk) - Dso.sum_picked_num(kk));

            end

            MM(iO,:) = M(:);
            MS = MS + M;
        end
        [jod, stats] = pw_scale_bootstrp( MM, bootstrap_samples, { 'use_parallel', 'never' } );
        stats.jod = jod;
        stat_arr = [stat_arr; stats];
    end
    scaled = array2table(stat_arr, 'VariableNames', {'stats'});
    scaled.refresh_rate = refresh_rates;
    if strcmpi(cache_name, 'unpredictable')
        scaled.stats(4).jod_low = scaled.stats(4).jod_low - scaled.stats(4).jod;
        scaled.stats(4).jod_high = scaled.stats(4).jod_high - scaled.stats(4).jod;
        scaled.stats(4).jod(2) = 0;
    end
    scaled.jod = arrayfun(@(r)r.jod', scaled.stats, 'UniformOutput', false);
    scaled.techs = arrayfun(@(r)techs', scaled.stats, 'UniformOutput', false);
    save(cache_file, 'scaled');
end
