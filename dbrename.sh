#!/usr/bin/env bash

# Rename your MySQL databases easily with this simple shell script
#
# The MIT License
#
# Copyright (c) 2012 Ignacio de Tomás, http://inacho.es
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


user=root
oldname=
newname=

function usage
{
	printf "Usage: $0 [options] dbName newDbName\n"
	printf "Options:\n"
	printf "  -u user Username of MySQL. root by default.\n"
}

while getopts "u:" flag
do
  case $flag in
    u) user="$OPTARG";;
  esac
done

shift $((OPTIND-1))


oldname=$1
newname=$2

if [[ $oldname == '' || $newname == '' ]]; then
	usage
	exit 0
fi


echo "Enter the MySQL password for the user $user"

stty_orig=`stty -g`
stty -echo
read passwd
stty $stty_orig



mysqlconn="mysql -u $user -p$passwd"

tables=$($mysqlconn -N -e "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE table_schema='$oldname'")
newexists=$($mysqlconn -N -e "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE table_schema='$newname'")

if [[ $tables == '' ]]; then
	echo "Error: The database $oldname doesn't exists"
	exit 0
fi
if [[ $newexists != '' ]]; then
	echo "Error: The database $newname already exists"
	exit 0
fi

$mysqlconn -e "CREATE DATABASE $newname"
for name in $tables; do
     $mysqlconn -e "RENAME TABLE $oldname.$name to $newname.$name";
done;
$mysqlconn -e "DROP DATABASE $oldname"

echo "Database renamed successfully"
