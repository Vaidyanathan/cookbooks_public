# Cookbook Name:: rs_utils
# Recipe:: setup_timezone
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

log "Set system timezone."

if node.has_key? :rs_utils and node.rs_utils.has_key? :timezone and !(node.rs_utils.timezone.nil? or node.rs_utils.timezone.empty?)
  log "Set timezone to #{node.rs_utils.timezone}."
  link "/etc/localtime" do
    to "/usr/share/zoneinfo/#{node.rs_utils.timezone}"
  end
else 
  log "Attrbute timezone unset, skipping."
end

ruby_block "show_timezone" do
  block do
    Chef::Log.info("System timezone: #{Time.now.strftime("%z %Z")}#{File.readlink('/etc/localtime').gsub(/^/, ' (').gsub(/$/, ')') unless !File.symlink?('/etc/localtime')}.")
  end
end