# Cookbook Name:: sys_dns
# Recipe:: default

# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

unless platform?('mac_os_x')
package value_for_platform(
    [ "ubuntu", "debian" ] => { "default" => "libdigest-sha1-perl" },
    [ "centos", "redhat", "suse" ] => { "default" => "perl-Digest-SHA1" },
    [ "archlinux" ] => { "default" => "perl-digest-sha1" }
)

package value_for_platform(
    [ "ubuntu", "debian" ] => { "default" => "libdigest-hmac-perl" },
    [ "centos", "redhat", "suse" ] => { "default" => "perl-Digest-HMAC" },
    [ "archlinux" ] => { "default" => "perl-digest-hmac" }
)
  root_group = 'root'
else
  root_group = 'wheel'
end

directory "/opt/rightscale/dns" do
  owner "root"
  group root_group
  mode "0755"
  recursive true
end

cookbook_file "/opt/rightscale/dns/dnscurl.pl" do
  source "dnscurl.pl"
  owner "root"
  group root_group
  mode "0755"
  backup false
end

sys_dns "default" do
  provider "sys_dns_#{node['sys_dns']['choice']}"
  user node['sys_dns']['user']
  password node['sys_dns']['password']
  #persist true
  action :nothing
end