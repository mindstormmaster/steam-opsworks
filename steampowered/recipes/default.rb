# default recipe to install steam

user node['steam']['user'] do
  action :create
  home node['steam']['dir']
  shell '/bin/bash'
  system true
end

directory node['steam']['dir'] do
  owner node['steam']['user']
  group node['steam']['user']
  mode "0755"
  action :create
end

#execute "dpkg --add-architecture i386" do
#end


package "ia32-libs" do
  action :install
  only_if {['foo'].pack('p').size == 8}
end

remote_file "#{node['steam']['dir']}/steamcmd_linux.tar.gz" do
  source "http://media.steampowered.com/client/steamcmd_linux.tar.gz"
  action :create_if_missing
  owner node['steam']['user']
  group node['steam']['user']
  mode "755"
end

execute "tar -xvzf #{node['steam']['dir']}/steamcmd_linux.tar.gz" do
  cwd node['steam']['dir']
  user node['steam']['user']
  creates "#{node['steam']['dir']}/steam"
end

3.times do
  execute "./steamcmd.sh +force_install_dir ./ +quit" do
    cwd node['steam']['dir']
    user node['steam']['user']
    environment ({
      "HOME" => node['steam']['dir']
    })
    # Sometimes it updates and it returns 1 on successful update
    returns [0,1,134]
  end
end