# Cookbook Name:: sys_dns
# Recipe:: do_set_private

# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

include_recipe "sys_dns"

require 'socket'

def local_ip
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily
  UDPSocket.open do |s|
    s.connect '64.233.187.99', 1
    s.addr.last
  end
  ensure
    Socket.do_not_reverse_lookup = orig
end

if ! node.has_key?('cloud')
  private_ip = "#{local_ip}"
else
  private_ip = node['cloud']['public_ips'][0]
end

log "Detected private IP: #{private_ip}"

sys_dns "default" do
  id node['sys_dns']['id']
  address private_ip
  action :set_private
end

execute "set_private_ip_tag" do
  command "rs_tag --add 'node:private_ip=#{private_ip}'"
  only_if "which rs_tag"
end