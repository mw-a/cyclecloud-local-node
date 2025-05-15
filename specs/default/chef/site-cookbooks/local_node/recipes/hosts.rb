qs = "slurm"
if node[qs].nil?
  qs = "pbspro"
  return if node[qs].nil?
end
    
return if node[qs][:use_nodename_as_hostname].nil? or not node[qs][:use_nodename_as_hostname]

hostsfile = "/etc/hosts"

# Generate a Hosts file entry for the host if it doesn't already exist (to make MPIs happy)
node_ip = node[:cyclecloud][:instance][:ipv4]
nodename = node[:hostname]

# fully qualify local hostname based on DNS search list (not
# necessarily correct but good enough for us)
domain = node.fetch(:dns, {}).fetch(:search_list, "").split(",").first
fqdn = "#{nodename}.#{domain}"

hosts_line = "#{node_ip}        #{fqdn} #{nodename}"

ruby_block "Update #{hostsfile} once more for nodename" do
  block do
    file = Chef::Util::FileEdit.new(hostsfile)
    file.search_file_delete_line(node_ip.to_s)
    file.insert_line_if_no_match(hosts_line, hosts_line)
    file.write_file
  end
end
