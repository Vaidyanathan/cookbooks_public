#
# Cookbook Name::app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "  Updating project code repository"
app "default" do
  persist true
  destination node[:app][:destination]
  action :code_update
end

include_recipe "app::setup_db_connection" if node['app']['setup_db_after_update_code'] == 'true'

rs_utils_marker :end