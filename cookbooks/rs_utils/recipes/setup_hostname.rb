# Cookbook Name:: rs_utils
# Recipe:: setup_hostname
#
# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

def show_host_info
  # Display current hostname values in log
  log "Hostname: #{`hostname`.strip == '' ? '<none>' : `hostname`.strip}"
  log "Network node hostname: #{`uname -n`.strip == '' ? '<none>' : `uname -n`.strip}"
  log "Alias names of host: #{`hostname -a`.strip == '' ? '<none>' : `hostname -a`.strip}"
  log "Short host name (cut from first dot of hostname): #{`hostname -s`.strip == '' ? '<none>' : `hostname -s`.strip}"
  log "Domain of hostname: #{`domainname`.strip == '' ? '<none>' : `domainname`.strip}"
  log "FQDN of host: #{`hostname -f`.strip == '' ? '<none>' : `hostname -f`.strip}"
  log "IP addresses for the hostname: #{`hostname -i`.strip == '' ? '<none>' : `hostname -i`.strip}"
end

# set hostname from short or long (when domain_name set)
unless node.rs_utils.domain_name.nil? || node.rs_utils.domain_name == ''  
  hostname = "#{node.rs_utils.short_hostname}.#{node.rs_utils.domain_name}"
  hosts_list = "#{node.rs_utils.short_hostname}.#{node.rs_utils.domain_name} #{node.rs_utils.short_hostname}"
else
  hostname = "#{node.rs_utils.short_hostname}"
  hosts_list = "#{node.rs_utils.short_hostname}"
end

# show current host info
log  "Setting hostname for '#{hostname}'."
log "== Current host/node information =="
show_host_info

# get node IP
node_ip = "#{local_ip}"
log "Node IP: #{node_ip}"

# Update /etc/hosts
log 'Configure /etc/hosts'
template "/etc/hosts" do
  source "hosts.erb"
  variables(
    :node_ip => node_ip,
    :hosts_list => hosts_list
    )
end

# Update /etc/hostname
log 'Configure /etc/hostname'
file "/etc/hostname" do
  owner "root"
  group "root"
  mode "0755"
  content "#{node.rs_utils.short_hostname}"
  action :create
end

#
# Update /etc/resolv.conf
#
log 'Configuring /etc/resolv.conf.'

# assumes the minimum option(s) in resolv.conf is a namserver
nameserver = "nameserver #{`cat /etc/resolv.conf | grep -v '^#' | grep nameserver | awk '{print $2}' | tr -d '\n'`}"

if !node.rs_utils.search_suffix.nil? and node.rs_utils.search_suffix != ""
  search = "search #{node.rs_utils.search_suffix}"
else
  current_search = "#{`cat /etc/resolv.conf | grep -v '^#' | grep search | awk '{print $2}' | tr -d '\n'`}"
  if current_search != ""
    search = "search #{current_search}"
  end
end

if !node.rs_utils.domain_name.nil? and node.rs_utils.domain_name != "" and search != ""
   domain = "domain #{node.rs_utils.domain_name}"
else

template "/etc/resolv.conf" do
  source "resolv.conf.erb"
  owner "root"
  mode "0644"
  variables(
    :nameserver => "#{nameserver}",
    :domain => "#{domain}",
    :search => "#{search}"
    )
end

# Call hostname command
log 'Setting hostname.'
if platform?('centos', 'redhat')
  bash "set_hostname" do
    code <<-EOH
      sed -i "s/HOSTNAME=.*/HOSTNAME=#{hostname}/" /etc/sysconfig/network
      hostname #{hostname}
    EOH
  end
else
  bash "set_hostname" do
    code <<-EOH
      hostname #{hostname}
    EOH
  end
end

# Call domainname command
if !node.rs_utils.domain_name.nil? || node.rs_utils.domain_name != ""
  log 'Running domainname'
  bash "set_domainname" do
    code <<-EOH
      domainname #{node.rs_utils.domain_name}
      EOH
  end
end

# restart  hostname services on appropriate platforms
if platform?('ubuntu')
  log 'Starting hostname service.'
  service "hostname" do
    service_name "hostname"
    supports :restart => true, :status => true, :reload => true
    action :restart
  end
end
if platform?('debian')
  log 'Starting hostname.sh service.'
  service "hostname.sh" do
    service_name "hostname.sh"
    supports :restart => false, :status => true, :reload => false
    action :start
  end
end

# rightlink commandline tools set tag with rs_tag
execute "set_rs_hostname_tag" do
    command "( if type -P rs_tag &>/dev/null; then rs_tag --add 'node:hostname=#{hostname}'; fi ) || true"    # exits 127 or similar, though not from command line (not sure why)
end
  
# Show the new host/node information
ruby_block "show_new_host_info" do
  block do
    # show new host values from system
    Chef::Log.info("== New host/node information ==")
    Chef::Log.info("Hostname: #{`hostname`.strip == '' ? '<none>' : `hostname`.strip}")
    Chef::Log.info("Network node hostname: #{`uname -n`.strip == '' ? '<none>' : `uname -n`.strip}")
    Chef::Log.info("Alias names of host: #{`hostname -a`.strip == '' ? '<none>' : `hostname -a`.strip}")
    Chef::Log.info("Short host name (cut from first dot of hostname): #{`hostname -s`.strip == '' ? '<none>' : `hostname -s`.strip}")
    Chef::Log.info("Domain of hostname: #{`domainname`.strip == '' ? '<none>' : `domainname`.strip}")
    Chef::Log.info("FQDN of host: #{`hostname -f`.strip == '' ? '<none>' : `hostname -f`.strip}")
    Chef::Log.info("IP addresses for the hostname: #{`hostname -i`.strip == '' ? '<none>' : `hostname -i`.strip}")
  end
end
