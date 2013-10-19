

execute "./steamcmd.sh +login bladesymphony abc123 +force_install_dir ./BladeSymphony +app_update 228780 validate +quit" do
  cwd node['steam']['dir']
  user node['steam']['user']
  environment ({
    "HOME" => node['steam']['dir']
  })
end

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

template "#{node['steam']['dir']}/BladeSymphony/berimbau/cfg/server_duel.cfg" do
  source "server.cfg.erb"
  mode 0440
  owner node['steam']['user']
  variables({
  	"gs" => {
      "name" => "#{node['steam']['server_name']} Duel",
      "rconPassword" => node['steam']['rcon_password'],
      "ranked" => true,
      "mode" => "1v1"
  	}
  })
end

