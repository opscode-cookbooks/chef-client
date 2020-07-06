# include helper methods
class ::Chef::Recipe
  include ::Opscode::ChefClient::Helpers
end

require 'chef/version_constraint'

# libraries/helpers.rb method to DRY directory creation resources
client_bin = find_chef_client
Chef::Log.debug("Using #{node['chef_client']['dist']}-client binary at #{client_bin}")
node.default['chef_client']['bin'] = client_bin

create_chef_directories

template "/Library/LaunchDaemons/com.#{node['chef_client']['dist']}.#{node['chef_client']['dist']}-client.plist" do
  source 'com.chef.chef-client.plist.erb'
  mode '0644'
  variables(
    client_bin: client_bin,
    daemon_options: node['chef_client']['daemon_options'],
    interval: node['chef_client']['interval'],
    launchd_mode: node['chef_client']['launchd_mode'],
    log_dir: node['chef_client']['log_dir'],
    log_file: node['chef_client']['log_file'],
    splay: node['chef_client']['splay'],
    working_dir: node['chef_client']['launchd_working_dir']
  )
  notifies :restart, "macosx_service[com.#{node['chef_client']['dist']}.#{node['chef_client']['dist']}-client]" if node['chef_client']['launchd_self-update']
end

macosx_service "com.#{node['chef_client']['dist']}.#{node['chef_client']['dist']}-client" do
  action :nothing
end

macosx_service "#{node['chef_client']['dist']}-client" do
  service_name "com.#{node['chef_client']['dist']}.#{node['chef_client']['dist']}-client"
  plist "/Library/LaunchDaemons/com.#{node['chef_client']['dist']}.#{node['chef_client']['dist']}-client.plist"
  action :start
end
