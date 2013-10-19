default['steam']['user'] = 'ubuntu'
default['steam']['dir'] = '/home/ubuntu'
default['steam']['username'] = ''
default['steam']['password'] = ''
if defined? node[:opsworks][:instance][:hostname]
  default['steam']['server_name'] = node[:opsworks][:instance][:hostname]
else 
  default['steam']['server_name'] = 'Blade Symphony'	
end

default['steam']['rcon_password'] = ''

default['steam']['supervisor'] = false
default['steam']['servers'] = [
	{
		"screen_name" => "dedi_duel",
		"name" => "Duel #1",
		"port" => 27015,
		"default_map" => "duel_winter",
		"mode" => "1v1",
		"ranked" => true
	}
]