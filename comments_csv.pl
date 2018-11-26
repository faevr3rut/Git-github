#!/usr/bin/perl -w
use strict;
use warnings;
#use lib "//plm/pnnas/apbuild/assem/scripts/assemBuildPerforce/lib";
use DBI;
#use dbRelated;
use Text::CSV;
use Data::Dumper;
my @PrArray;
#--------------------History-------------
#Rutuja Toradmal  26-11-2018 Script for retriving the comments data as per CP number.
open(my $handler, "<", "D:/Code_to_connect/2015_final_cp.txt") or die "failed to open file : $!\n"; 
while(<$handler>)
{
	chomp;
	push @PrArray, $_;
}
close $handler;

my $dbh = DBI->connect("dbi:mysql:DMSCYP:do-dmscyprep:3306", "dmscyprep", "");#connection to dmscyp database
my $csv = Text::CSV->new ( { binary => 1 ,  eol => $/} ) or die "Cannot use CSV: ".Text::CSV->error_diag ();   # should set binary attribute.

open my $fh, ">",  "2015_CPcomments.csv" or die "test.csv: $!"; 
$csv->print($fh, ["cpId","cpOwner_username","cpOwner_Fname","cpOwner_Lname","fileName","cpReviewver_id","reviewComment","reviewver_Fname","reviewver_Lname","reviewver_username"]);

my $i = 0;

foreach my $pr (@PrArray)
{

 my $sqlquery='select distinct c1.name as CPName,i1.username,p1.tc_name_first, p1.tc_name_last,s1.name,identryowner,c5.authorText, p2.tc_name_first,p2.tc_name_last, i2.username
from changepackage c1 inner join cpproblemreport c2 inner join cpproblemreportincp c3 inner join crcomment c4 inner join people p1 inner join
 internalusers i1 inner join sourcefile s1 inner join crauthorentry  c5 inner join people p2 inner join internalusers i2
 where c1.idchangepackage=c3.idchangepackage and c2.idcpproblemreport=c3.idcpproblemreport and c4.idchangepackage=c1.idchangepackage and s1.idsourcefile=c4.idsourcefile and c5.authorText!=" "
 and c5.idcrcomment=c4.id and  c1.idinternalusers=i1.IDInternalUsers and i1.username=p1.tc_username and i2.IDInternalUsers=c5.identryowner
 and i2.username=p2.tc_username and c1.name= ? ';
 
my $sth = $dbh->prepare($sqlquery);
$sth->execute($pr);
while (my @row = $sth->fetchrow_array)
{
print @row;
	 # if (defined $row[6] && length $row[6]>0)
	# {
	$csv->print($fh, \@row);
	# }
	 # else
	 # {
	
	 # print "empty comment was not printed";
	# }
				
}
 	

}

close $fh;
