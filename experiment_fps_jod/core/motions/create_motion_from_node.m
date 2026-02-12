function motion = create_motion_from_node(node)
    % deserialise a struct node to a motion (of the proper class)
    motion = eval(node.class);
    motion = motion.initWithNode(node);
end