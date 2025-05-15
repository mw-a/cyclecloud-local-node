qs = "slurm"
if node[qs].nil?
  qs = "pbspro"
  return if node[qs].nil?
end
    
return if node[qs][:use_nodename_as_hostname].nil? or not node[qs][:use_nodename_as_hostname]

hostsfile = "/etc/hosts"

# Generate a Hosts file entry for the host if it doesn't already exist (to make MPIs happy)
node_ip = node[:cyclecloud][:instance][:ipv4]
hostname = node[:hostname]

# nodename will not be updated yet during first converge with PBS
is_compute = node.fetch(:roles, []).include?("pbspro_execute_role")
if is_compute
  nodename = node[:cyclecloud][:node][:name]
  node_prefix = node[:pbspro][:node_prefix]
  if !node_prefix.empty?
    hostname = "#{node_prefix}#{nodename}"
  end
end

# fully qualify local hostname based on DNS search list (not
# necessarily correct but good enough for us)
domain = node.fetch(:dns, {}).fetch(:search_list, "").split(",").first
fqdn = "#{hostname}.#{domain}"

hosts_line = "#{node_ip}        #{fqdn} #{hostname}"

ruby_block "Update #{hostsfile} once more for hostname" do
  block do
    file = Chef::Util::FileEdit.new(hostsfile)
    file.search_file_delete_line(node_ip.to_s)
    file.insert_line_if_no_match(hosts_line, hosts_line)
    file.write_file
  end
end
