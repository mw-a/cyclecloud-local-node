# Return if mounts is undefined.
return unless node['cyclecloud'].key?('mounts')

# Should never hit this, return if mounts is initialized.
return if node['cyclecloud']['mounts'].nil? || node['cyclecloud']['mounts'].empty?

mounts = node[:cyclecloud][:mounts].sort_by { |_k, v| v[:order] || 1000 }
mounts.each_with_index do |(name, mp), _index|
	next unless CVolume.device_mountpoint?(mp)

	# in Chef 11 node attributes are immutable, so let's convert this to a hash
	mp = ::Hash[mp.map { |(k, v)| [k.to_sym, v] }]

	next if mp[:disabled] == true

	mp[:mountpoint] = "/media/#{name}" if mp[:mountpoint].nil?

	device = node.run_state[:mounts][name][:device]
	if CVolume.formatted?(device)
		device_name = device
	else
		# Determine if encrypted, and what the default device_name should be
		lv_name = mp[:lv_name] || 'lv0'
		vg_name = mp[:vg_name] || "vg_cyclecloud_#{name}"
		if (mp[:encryption].nil? || mp[:encryption].empty?) && node[:cyclecloud][:mount_defaults][:encryption][:bits].nil?
			device_name = "/dev/mapper/#{vg_name}-#{lv_name}"
		else
			crypt_name = mp[:encryption][:name] || "cyclecloud_crypt_#{name}"
			device_name = "/dev/mapper/#{crypt_name}"
		end
	end

	Chef::Log.debug("Enable mountpoint #{name} at #{mp[:mountpoint]} of device #{device_name} order #{mp[:order] || 1000}")

	# Enable mount at mp[:mountpoint]
	mount mp[:mountpoint] do
		action :enable
		device device_name
		fstype mp[:fs_type]
		options mp[:options]
		not_if { mp[:no_format] }
	end
end
