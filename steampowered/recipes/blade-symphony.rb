



# quit all running servers
node['steam']['servers'].each do |server|
  if node['steam']['supervisor']
    supervisor_service "#{server['screen_name']}" do
      action :stop
    end
  else	
    execute "screen -S #{server['screen_name']} -X quit" do
      cwd node['steam']['dir']
      user node['steam']['user']
      environment ({
        "HOME" => node['steam']['dir']
      })
      returns [0,1]
    end
  end
end




# update blade symphony

execute "./steamcmd.sh +login #{node['steam']['username']} #{node['steam']['password']} +force_install_dir ./BladeSymphony +app_update 228780 validate +quit" do
  cwd node['steam']['dir']
  user node['steam']['user']
  environment ({
    "HOME" => node['steam']['dir']
  })
end

# create config files

template "#{node['steam']['dir']}/BladeSymphony/berimbau/maplist_ffa.txt" do
  source "maplist_ffa.txt.erb"
  mode 0440
  owner node['steam']['user']
  variables({
  })
end

template "#{node['steam']['dir']}/BladeSymphony/berimbau/maplist_duel.txt" do
  source "maplist_duel.txt.erb"
  mode 0440
  owner node['steam']['user']
  variables({
  })
end

template "#{node['steam']['dir']}/helper_start_server.sh" do
  source "helper_start_server.sh.erb"
  mode 0550
  owner node['steam']['user']
  variables({
  })
end





if node['steam']['supervisor']
  include_recipe "supervisor"

  directory "#{node['steam']['dir']}/supervisor" do
    owner node['steam']['user']
    group node['steam']['user']
    mode "0755"
    action :create
  end

  execute "echo '225600' > #{node['steam']['dir']}/BladeSymphony/steam_appid.txt" do
 	user node['steam']['user']
  end
else
  package "screen" do
    action :install
  end
end

node['steam']['servers'].each do |server|
    # create server config files
	template "#{node['steam']['dir']}/BladeSymphony/berimbau/cfg/server_#{server['screen_name']}.cfg" do
	  source "server.cfg.erb"
	  mode 0440
	  owner node['steam']['user']
	  variables({
	  	"gs" => {
	      "name" => "#{node['steam']['server_name']} #{server['name']}",
	      "rconPassword" => node['steam']['rcon_password'],
	      "ranked" => server['ranked'],
	      "mode" => server['mode']
	  	}
	  })
	end


  if node['steam']['supervisor']
  	# start server using supervisor
	supervisor_service "#{server['screen_name']}" do
	  action :enable
	  directory "#{node['steam']['dir']}/BladeSymphony"
	  command "#{node['steam']['dir']}/BladeSymphony/srcds_linux +maxplayers 16 +map #{server['default_map']} +servercfgfile server_#{server['screen_name']}.cfg +port #{server['port']}"
	  user node['steam']['user']

	  stdout_logfile "#{node['steam']['dir']}/supervisor/#{server['screen_name']}.log"
	  stdout_logfile_backups 10

	  environment ({
	    "LD_LIBRARY_PATH" => ".:bin:$LD_LIBRARY_PATH"
	  })
	end
  else	
  	# start server using screen
    execute "./helper_start_server.sh #{server['screen_name']} server_#{server['screen_name']}.cfg #{server['port']} #{server['default_map']}" do
      cwd "#{node['steam']['dir']}"
      user node['steam']['user']
    end
  end
end






