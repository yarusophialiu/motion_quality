function trial = createTrialFromSerialisationNode(node)
    class_name = node.class;
    trial = eval([class_name '()']); 
    trial = trial.initWithNode(node);
end