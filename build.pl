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
use File::Spec::Functions qw(catfile);

my $root_dir = dirname(abs_path(__FILE__));
my $cmake_gen_name = "Visual Studio 17 2022";
my $cmake_build_type = "Release";
if (defined($ARGV[0]) && (uc($ARGV[0]) eq 'DEBUG')) {
  $cmake_build_type = "Debug";
}

sub ensure_dir_empty {
  my $dir = shift;
  if (-d $dir) {
    remove_tree($dir) or die("$!");
  }
  make_path($dir) or die("$!");
}

sub build_cmake_project {
  my $dir_rel = shift;
  print("\nBuilding project: [$dir_rel]\n");
  my $src_dir = catfile($root_dir, "contrib", $dir_rel);
  my $build_dir = catfile($src_dir, "build");
  ensure_dir_empty($build_dir);
  chdir($build_dir);
  my $conf_cmd = "cmake ..";
  $conf_cmd .= " -G \"$cmake_gen_name\"";
  print("$conf_cmd\n");
  0 == system($conf_cmd) or die("$!");
  my $build_cmd = "cmake --build .";
  $build_cmd .= " --config $cmake_build_type";
  print("$build_cmd\n");
  0 == system($build_cmd) or die("$!");
  my $install_cmd = "$build_cmd --target install";
  print("$install_cmd\n");
  0 == system($install_cmd) or die("$!");
}

chdir(catfile($root_dir, "contrib"));
print("Cleaning up repo\n");
0 == system("git clean -dxf") or die("$!");
0 == system("git status") or die("$!");

build_cmake_project("babelfishpg_money");
build_cmake_project("babelfishpg_common");
build_cmake_project("babelfishpg_tds");
build_cmake_project("babelfishpg_tsql/antlr");
build_cmake_project("babelfishpg_tsql");

print("Build complete successfully\n");