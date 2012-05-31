#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Set a default provider for app to connect with lb cookbook attach/detach
# for application servers without their own provider.
set_unless[:app][:provider] = "app"
# By default listen on port 8000
set_unless[:app][:port] = "8000"

# By default listen on the first private IP
def local_ip
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily
  UDPSocket.open do |s|
    s.connect '64.233.187.99', 1
    s.addr.last
  end
  ensure
    Socket.do_not_reverse_lookup = orig
end

if node['cloud']
  default[:app][:ip] = node[:cloud][:private_ips][0]
else
  default[:app][:ip] = local_ip
end
