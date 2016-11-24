use strict;
use DBD::Oracle;


my $db = "dbname";
my $user = "user";
my $pass = "password";

my $dbh = DBI->connect( "dbi:Oracle:$db", $user, $pass ) ;



$dbh->disconnect()
