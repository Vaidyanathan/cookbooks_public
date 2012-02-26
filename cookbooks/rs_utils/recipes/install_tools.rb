# Cookbook Name:: rs_utils
# Recipe:: install_tools
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

log 'Install RightScale Tools.'

if !node.has_key? :rightscale
  log 'Not attached to RightScale, skipping tags setup.'
  return
end

package "make"  # needed for 0.8 where build-essential cookbook does not work

directory "/var/rightscale/cache/rubygems" do
  mode "0775"
  owner "root"
  group "root"
  recursive true
end

RS_SANDBOX_GEM_BINARY="/opt/rightscale/sandbox/bin/gem"

#
# right_rackspace
#
gem_package "right_rackspace" do
  source "/var/rightscale/cache/rubygems/right_rackspace-0.0.0.20111110.gem"
  version "0.0.0.2"
  gem_binary "#{RS_SANDBOX_GEM_BINARY}"
  action :nothing
end

remote_file "/var/rightscale/cache/rubygems/right_rackspace-0.0.0.20111110.gem" do
  source "https://github.com/rightscale/cookbooks_public/blob/bb0d95a42f2d897768344b2430fe872bd6158a81/cookbooks/rs_utils/files/default/right_rackspace-0.0.0.20111110.gem"
  action :nothing
  mode "07775"
  notifies :install, resources(:gem_package => "right_rackspace"), :delayed
end

http_request "HEAD https://github.com/rightscale/cookbooks_public/blob/bb0d95a42f2d897768344b2430fe872bd6158a81/cookbooks/rs_utils/files/default/right_rackspace-0.0.0.20111110.gem" do
  message ""
  url "https://github.com/rightscale/cookbooks_public/blob/bb0d95a42f2d897768344b2430fe872bd6158a81/cookbooks/rs_utils/files/default/right_rackspace-0.0.0.20111110.gem"
  action :head
  if File.exists?("/var/rightscale/cache/rubygems/right_rackspace-0.0.0.20111110.gem")
    headers "If-Modified-Since" => File.mtime("/var/rightscale/cache/rubygems/right_rackspace-0.0.0.20111110.gem").httpdate
  end
  notifies :create, resources(:remote_file => "/var/rightscale/cache/rubygems/right_rackspace-0.0.0.20111110.gem"), :immediately
end


#
# rightscale_tools_public
#
gem_package "rightscale_tools_public" do
  source "/var/rightscale/cache/rubygems/rightscale_tools_public-1.0.26.gem"
  version "1.0.26"
  gem_binary "#{RS_SANDBOX_GEM_BINARY}"
  action :nothing
end

remote_file "/var/rightscale/cache/rubygems/rightscale_tools_public-1.0.26.gem" do
  source "https://github.com/rightscale/cookbooks_public/blob/bb0d95a42f2d897768344b2430fe872bd6158a81/cookbooks/rs_utils/files/default/rightscale_tools_public-1.0.26.gem"
  action :nothing
  mode "07775"
  notifies :install, resources(:gem_package => "rightscale_tools_public"), :delayed
end

http_request "HEAD https://github.com/rightscale/cookbooks_public/blob/bb0d95a42f2d897768344b2430fe872bd6158a81/cookbooks/rs_utils/files/default/rightscale_tools_public-1.0.26.gem" do
  message ""
  url "https://github.com/rightscale/cookbooks_public/blob/bb0d95a42f2d897768344b2430fe872bd6158a81/cookbooks/rs_utils/files/default/rightscale_tools_public-1.0.26.gem"
  action :head
  if File.exists?("/var/rightscale/cache/rubygems/rightscale_tools_public-1.0.26.gem")
    headers "If-Modified-Since" => File.mtime("/var/rightscale/cache/rubygems/rightscale_tools_public-1.0.26.gem").httpdate
  end
  notifies :create, resources(:remote_file => "/var/rightscale/cache/rubygems/rightscale_tools_public-1.0.26.gem"), :immediately
end