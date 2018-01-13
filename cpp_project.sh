# This script initialize a new automake project.
# Copyright (C) 2017 Gabriele Labita
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Usage:
# > ./cpp_project.sh <name_of_the_project>
#
# Create the a new c++ project based on autotools, with the name:
# name_of_the_project

if [ $# -ne 1 ]; then
    echo "Invalid arguments. You must specified name of the project."
    echo "Usage: "
    echo " > ./cpp_project.sh name_of_the_project"
    exit 1
fi
if [ ! -d "$1" ]; then
   mkdir $1
else
    echo "$1 Exists. Cannot create a new project."
    exit 1
fi

cd $1

echo "CURRENT=\$(dirname \".\")
CURRENT=\$(readlink -f \$CURRENT)

DIR=\$(dirname \"\$0\")
DIR=\$(readlink -f \$DIR)

if [ ! -d \"\$DIR/build\" ]; then
    mkdir build
fi
BUILDDIR=\"\$DIR/build\"

if [ -f \"\$BUILDDIR/Makefile\" ]; then
    cd \$BUILDDIR
    make clean
fi

cd \$DIR

cd \$BUILDDIR
../configure
make all

cd \$CURRENT" >> rebuild.sh

echo "CURRENT=\$(dirname \".\")
CURRENT=\$(readlink -f \$CURRENT)

DIR=\$(dirname \"\$0\")
DIR=\$(readlink -f \$DIR)

cd \$DIR

BUILDDIR=\"\$DIR/build\"

if [ ! -d \"\$DIR/build\" ]; then
    mkdir build
    cd \$BUILDDIR
    ../configure
fi
cd \$BUILDDIR

make all

cd \$CURRENT" >> build.sh

chmod +x rebuild.sh
chmod +x build.sh
#Create Directories
mkdir src
mkdir test

#Create Autotools Files
touch LICENSE
touch README
touch COPYING
touch AUTHORS
touch ChangeLog
touch NEWS

echo "$USER" >> AUTHORS
echo "
     #USEFULL CONFIGURATION OPTIONS

     Give a prefix to the name of the project:
      > configure --program-prefix put_prefix_here

     Perform a cross compilation
      > configure --host [hostsystem] --target [target-system]
" >> INSTALL

echo "AC_INIT([$1], [1.0.0], [author-$USER])
AM_INIT_AUTOMAKE([-Wall -Werror subdir-objects])
AC_PROG_CXX
AC_CONFIG_HEADERS([config.h])

AC_CONFIG_FILES([
        Makefile
        src/Makefile
        test/Makefile
])

AC_OUTPUT" >> configure.ac

echo "SUBDIRS = src test
dist_doc_DATA = README" >> Makefile.am

echo "bin_PROGRAMS = $1
$1_SOURCES = main.cc

# Some usefull notes are reported below.
# 01. To add an existing library use -l options
#      $1_LDADD =  -lib
#
# 02. To add some custom flag to the project use _CXXFLAGS
#      $1_CXXFLAGS = -std=c++17
#
# 03. To compile an inner static library use noinst_, this avoid the
#     installation (static library must be linked directly to the the
#     compiled file).
#      noinst_LIBRARIES = libstaticlibname.a
#      libstaticlibname_a_SOURCES = ... list of sources ...
#
#      bin_PROGRAM = $1
#      $1_SOURCES = ....
#      $1_LDADD = libstaticlibname.a
#
#     Remember to add AC_PROG_RANLIB macro in configure.ac
#     AC_PROG_RANLIB: This is required if any libraries are built in
#                     the package. See Particular Program Checks in
#                     The Autoconf Manual. 
" >> src/Makefile.am

echo "#include<iostream>

int main() {
    std::cout << \"Hello!\" << std::endl;
    return 0;
}" >> src/main.cc


# Test Generation

echo "#include \"./sample_test.cc\"
#include \"CppUTest/CommandLineTestRunner.h\"

int main(int ac, char** av)
{
    return CommandLineTestRunner::RunAllTests(ac, av);
}
" >> test/cpputest_main.cc
echo "#include <CppUTest/TestHarness.h>
#include <CppUTestExt/MockSupport.h>


TEST_GROUP(TestGroupName) {
    void setup() { }
    void teardown() {
        mock().clear();
    }
};

/**
 * HAVE Initial environment
 * WHEN Perform an action
 * THEN This happens
 */
TEST(TestGroupName, Test_01) {
    CHECK_EQUAL(\"Expectation\", \"Expectation\");
}" >> test/sample_test.cc

echo "AM_CXXFLGAS = -W -Wall
LDADD = -lCppUTest -lCppUTestExt
check_PROGRAMS = $1
$1_SOURCES = cpputest_main.cc" >> test/Makefile.am

autoreconf --install
exit 0
