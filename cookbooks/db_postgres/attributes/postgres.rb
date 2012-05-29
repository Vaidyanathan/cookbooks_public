#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
#
default[:db_postgres][:server_usage] = "dedicated"  # or "shared"
default[:db_postgres][:previous_master] = nil


# Optional attributes
#
default[:db_postgres][:port] = "5432"
default[:db_postgres][:version] = "9.1"

default[:db_postgres][:tmpdir] = "/tmp"
default[:db_postgres][:ident_file] = ""
default[:db_postgres][:pid_file] = ""
default[:db_postgres][:datadir_relocate] = "/mnt/storage"
default[:db_postgres][:bind_address] = cloud[:private_ips][0]

# Platform specific attributes

case platform
when "centos"
  set[:db_postgres][:socket] = "/var/run/postgresql"
  default[:db_postgres][:basedir] = "/var/lib/pgsql/#{node[:db_postgres][:version]}"
  default[:db_postgres][:confdir] = "/var/lib/pgsql/#{node[:db_postgres][:version]}/data"
  default[:db_postgres][:datadir] = "/var/lib/pgsql/#{node[:db_postgres][:version]}/data"
  default[:db_postgres][:bindir] = "/usr/pgsql-#{node[:db_postgres][:version]}/bin"
  default[:db_postgres][:packages_uninstall] = ""
  default[:db_postgres][:log] = ""
  default[:db_postgres][:log_error] = ""
end