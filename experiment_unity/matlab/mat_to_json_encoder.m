function mat_to_json_encoder(lut_name)
%MAT_TO_JSON_ENCODER open LUT with given name, then encode as a json file
%so unity can open it
    
    mat = load(lut_name);

    data = struct();
    data.display = lut_name;
    data.velocities = mat.velocities;
    data.bandwidths = round(mat.bandwidths);
    data.refreshRatesPred = mat.refresh_rates_pred(:);
    data.refreshRatesUnpred = mat.refresh_rates_unpred(:);
    data.displayMaxWidth = 2560;
    data.displayMaxHeight = 1440;
    data.displayMaxRR = 165;
    
    data_str = jsonencode(data);
    fileID = fopen(sprintf('%s_LUT.json', lut_name),'w');
    fprintf(fileID, '%s', data_str);
    fclose(fileID);
end

