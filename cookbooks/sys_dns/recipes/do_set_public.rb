# Cookbook Name:: sys_dns
# Recipe:: do_set_public

# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

if ! node.has_key?('cloud')
  public_ip=`curl -s http://icanhazip.com/`.strip
  log "Detected public IP: #{public_ip}"
else
  public_ip = node['cloud']['public_ips'][0]
end

sys_dns "default" do
  id node['sys_dns']['id']
  address public_ip
  action :set_public
end