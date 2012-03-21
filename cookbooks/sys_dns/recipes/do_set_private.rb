# Cookbook Name:: sys_dns
# Recipe:: do_set_private

# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

sys_dns "default" do
  id node['sys_dns']['id']
  address node['cloud']['private_ips'][0]
  action :set_private
end