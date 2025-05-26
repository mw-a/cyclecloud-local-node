name "local_node_role"
description "Local changes to nodes"
run_list("recipe[local_node::hosts]", "recipe[local_node::permanent_mounts]")
