name "local_node_role"
description "Local changes to nodes"
run_list("recipe[local_node::hosts]")
