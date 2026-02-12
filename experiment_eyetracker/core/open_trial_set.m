function trialSet = open_trial_set(path)
    text = fileread(path);
    node = jsondecode(text);
    trialSet = TrialSet().initWithNode(node);
end

