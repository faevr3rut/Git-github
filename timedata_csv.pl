#!/usr/bin/perl -w
use strict;
use warnings;
#use lib "//plm/pnnas/apbuild/assem/scripts/assemBuildPerforce/lib";
use DBI;
#use dbRelated;
use Text::CSV;
use Data::Dumper;
my @PrArray;

open(my $handler, "<", "D:/Code_to_connect/2015_final_cp.txt") or die "failed to open file : $!\n"; 
while(<$handler>)
{
	chomp;
	push @PrArray, $_;
}
close $handler;

my $dbh = DBI->connect("dbi:mysql:DMSCYP:do-dmscyprep:3306", "dmscyprep", "");#connection to dmscyp database
my $csv = Text::CSV->new ( { binary => 1 ,  eol => $/} ) or die "Cannot use CSV: ".Text::CSV->error_diag ();   # should set binary attribute.

open my $fh, ">",  "2015_PR_WithCP.csv" or die "test.csv: $!"; 
$csv->print($fh, ["cpId","cpType", "OpenDate" , "closedDate","cpStatus","prRefId"]);

my $i = 0;

foreach my $pr (@PrArray)
{

my @sqlquery=sql("select distinct c.name,c.kind as cpType,d.ts as CP_open_time,c.timer as close_time, c.state,cpr.number from changepackage c inner join cpproblemreportincp p 
inner join cpdiary d inner join cpproblemreport cpr where p.idcpproblemreport=cpr.idcpproblemreport and p.idchangepackage=c.idchangepackage 
  and c.idchangepackage=d.idchangepackage and c.name=\"$pr\" and c.state='closed' and d.event='open' and d.message like 'Change%' limit 1;");

 # print Dumper @sqlquery ;
  
  $i++;
print "\n Processing Record : $i";
  
 $csv->print($fh, \@sqlquery);

 

}

close $fh;

sub sql
{
    my ($sql) = @_;
    my $query = $dbh->prepare($sql);
    $query->execute();
	
    my @rows = @{$query->fetchall_arrayref};
    $query->finish();

	my @results = ();
	
	for my $row (@rows) {
		#push (@results, "\n");
		foreach my $t(@{$row})
		{
			$t =~ s/[\r\n]*//g;
			push(@results, $t) if (defined $t && $t ne "");
		}
		
	}
	
    return @results;
}