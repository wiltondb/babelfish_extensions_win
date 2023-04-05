# Copyright 2023 alex@staticlibs.net
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Path qw(make_path remove_tree);
use File::Slurp qw(append_file);
use File::Spec::Functions qw(catfile);

my $jdbc_dir = dirname(abs_path(__FILE__));

sub runcmd {
  my $cmd = shift;
  my $best_effort = shift;
  print("$cmd\n");
  0 == system($cmd) or die("$!");
}

if (!(defined $ENV{PGWIN_INSTALL_DIR})) {
  die("Environment variable 'PGWIN_INSTALL_DIR' (pointing to the postgresql_modified_for_babelfish installation directory) must be specified");
}

my $pg_ctl = catfile($ENV{PGWIN_INSTALL_DIR}, "bin", "pg_ctl.exe");
my $initdb = catfile($ENV{PGWIN_INSTALL_DIR}, "bin", "initdb.exe");
my $psql = catfile($ENV{PGWIN_INSTALL_DIR}, "bin", "psql.exe");
my $pg_data = catfile($ENV{PGWIN_INSTALL_DIR}, "data");
my $pg_log_dir = catfile($ENV{PGWIN_INSTALL_DIR}, "data", "log");
my $pg_log = catfile($ENV{PGWIN_INSTALL_DIR}, "data", "log", "postgresql.log");
my $postmaster_pid = catfile($ENV{PGWIN_INSTALL_DIR}, "data", "postmaster.pid");
my $postgresql_conf = catfile($ENV{PGWIN_INSTALL_DIR}, "data", "postgresql.conf");

if (-f $postmaster_pid) {
  runcmd("$pg_ctl stop -D $pg_data -l $pg_log", "best effort");
}
remove_tree($pg_data);
runcmd("$initdb -D $pg_data -E UTF8 --locale en_US");
append_file($postgresql_conf, "shared_preload_libraries = 'babelfishpg_tds'\n");
append_file($postgresql_conf, "babelfishpg_tds.port = 1435\n");
append_file($postgresql_conf, "allow_system_table_mods = on\n");
make_path($pg_log_dir);
runcmd("$pg_ctl start -D $pg_data -l $pg_log");

runcmd("$psql -d postgres  -c \"CREATE USER babelfish WITH SUPERUSER CREATEDB CREATEROLE PASSWORD 'babelfish' INHERIT;\"");
runcmd("$psql -d postgres  -c \"CREATE DATABASE babelfish OWNER babelfish;\"");
runcmd("$psql -d babelfish -c \"CREATE EXTENSION IF NOT EXISTS babelfishpg_tds CASCADE;\"");
runcmd("$psql -d babelfish -c \"GRANT ALL ON SCHEMA sys to babelfish;\"");
runcmd("$psql -d babelfish -c \"ALTER SYSTEM SET babelfishpg_tsql.database_name = 'babelfish';\"");
runcmd("$psql -d babelfish -c \"ALTER DATABASE babelfish SET babelfishpg_tsql.migration_mode = 'multi-db';\"");
runcmd("$psql -d babelfish -c \"SELECT pg_reload_conf();\"");
runcmd("$psql -d babelfish -c \"CALL sys.initialize_babelfish('babelfish');\"");

runcmd("mvn test");

runcmd("$pg_ctl stop -D $pg_data -l $pg_log");
perl("Test run comleted successfully\n");