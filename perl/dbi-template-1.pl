# !/usr/bin/perl -w
#
# Copyright: 	Jared Still
#				http://jaredstill.com/content/dbi-template.html
#
# This is a standard template that I start with when creating a Perl script that connects to an Oracle database.
#
# It has the advantage of having command line arguments in place via the Getopt::Long module, a database connection 
# via the DBI module, a sample query also via DBI, as well as some standard settings that I like to include in my Perl/Oracle scripts.
#
# RowCacheSize: This is set to 100. Each call to the Oracle database will fetch up to 100 rows. This reduces the number of trips to the 
#				database and can have quite a positive impact on performance. 100 may not be the optimal value in all situations, but it usually works well.
# orachecksql: 	This is set to 0. The default value is 1.
# 				If left to the default value , Oracle will be forced to parse each SQL statement an extra time for the describe. 
#				See the DBD::Oracle documentation for more details,
# AutoCommit: 	This is set to 0. 
#				Setting this explicitly is strongly recommended. The setting of 0 means that a "commit" will only take place when the $dbh->commit 
#				command is given. See the DBI documentation for more details.,
# RaiseError: 	This is set to 1. This means that all database error will raise an exception rather than just return an error code. 
#				This greatly eases dealing with errors returned by the database. This behavior can be overridden where necessary. 
#				As usual , see the DBI documentation for more details.
#


use warnings;
use DBI;
use strict;
use Getopt::Long;
my %optctl = ();

Getopt::Long::GetOptions(
   \%optctl, 
   "database=s",
   "username=s",
   "password=s",
   "sysdba!",
   "sysoper!",
   "z","h","help");

my($db, $username, $password, $connectionMode);
$connectionMode = 0;
if ( $optctl{sysoper} ) { $connectionMode = 4 }
if ( $optctl{sysdba} ) { $connectionMode = 2 }
if ( ! defined($optctl{database}) ) {
   Usage();
   die "database required\n";
}
$db=$optctl{database};
if ( ! defined($optctl{username}) ) {
   Usage();
   die "username required\n";
}
$username=$optctl{username};
$password = $optctl{password};

#print "USERNAME: $username\n";
#print "DATABASE: $db\n";
#print "PASSWORD: $password\n";
#exit;

my $dbh = DBI->connect(
   'dbi:Oracle:' . $db, 
   $username, $password, 
   { 
      RaiseError => 1, 
      AutoCommit => 0,
      orasessionmode => $connectionMode
   } 
   );



die "Connect to  $db failed \n" unless $dbh;
$dbh->{RowCacheSize} = 100;
my $sql=q{select  from dual};



my $sth = $dbh->prepare($sql,{orachecksql => 0 });
$sth->execute;
while( my $ary = $sth->fetchrowarrayref ) {
   print "\t\t$${ary[0]}\n";
}



$sth->finish;
$dbh->disconnect;



sub Usage {
   print "\n";
   print "usage:  DBItemplate.pl\n";
   print "    DBItemplate.pl -database dv07 -username scott -password tiger [-sysdba || -sysoper]\n";
   print "\n";
}