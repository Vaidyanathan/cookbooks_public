# Cookbook Name:: rs_utils
# Recipe:: setup_mail
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

package "postfix"
service "postfix"

# postfix package doesn't remove sendmail on redhat distros
remove_sendmail = value_for_platform(
  ["centos", "redhat", "suse", "fedora" ] => {
    "default" => true
  }
)

execute "set_postfix_default_mta" do
  command "alternatives --set mta /usr/sbin/sendmail.postfix"
  action :nothing
end

package "sendmail" do
  action :remove
  only_if { remove_sendmail }
  notifies :run, "execute[set_postfix_default_mta]", :immediately
end

# == Update main.cf (if needed)
# We make the changes needed for centos, but using the default main.cf 
# config everywhere else
template "/etc/postfix/main.cf" do
  only_if { node.platform == 'centos' }
  source "postfix.main.cf.erb"
  notifies :restart, resources(:service => "postfix"), :delayed
  mode "644"
end

directory "/var/spool/oldmail" do
  recursive true
  mode "775"
  owner "root"
  group "mail"
end

# Add mail to logrotate
template "/etc/logrotate.d/mail" do
  source "logrotate.d.mail.erb"
end
