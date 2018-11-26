use strict;
use warnings;
use lib "//plm/pnnas/apbuild/assem/scripts/assemBuildPerforce/lib";
use DBI;
use dbRelated;

my @PrArray;
open(my $handler, "<", "D:/Code_to_connect/2015_final_cp.txt") or die "failed to open file : $!\n"; 
while(<$handler>)
{
	chomp;
	push @PrArray, $_;
}
close $handler;

my $dbh = DBI->connect("dbi:mysql:DMSCYP:do-dmscyprep:3306", "dmscyprep", "");#connection to dmscyp database


foreach my $pr (@PrArray)
{

my @sqlquery=sql("select distinct c.name, s.name from  DMSCYP.changepackage c  join cpfile f join DMSCYP.sourcefile s where 
  c.idchangepackage=f.idchangepackage and f.idsourcefile=s.idsourcefile and f.type='target' and c.state='closed' and
 c.name=\"$pr\";");
 
print join("\t", @sqlquery);
	
}

sub sql
{
    my ($sql) = @_;
    my $query = $dbh->prepare($sql);
    $query->execute();
	
    my @rows = @{$query->fetchall_arrayref};
    $query->finish();
	
    # # if (scalar(@rows) == 1) {
        # # return $rows[0][0];
	# # }

	my @results = ();
	
	for my $row (@rows) {
		push (@results, "\n");
		foreach my $t(@{$row})
		{
			$t =~ s/[\r\n]*//g;
			push(@results, $t);
		}
		#push(@results, @{$row});
	}
	
    return @results;
}