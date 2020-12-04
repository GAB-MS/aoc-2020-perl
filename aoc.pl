#!/usr/bin/perl -w

use strict;
use warnings;
use English;
use FindBin;
use Getopt::Long;

my $gDay = undef;
my $lUsage = undef;
my $lOK = GetOptions('day=i'  => \$gDay,
                     'help|h' => \$lUsage);

$lOK or Usage("Invalid arguments supplied");
$lUsage and Usage();
defined($gDay) or Usage("Must supply a day");

eval
{
  my $lModule = "day$gDay";
  my $lModulePath = "$FindBin::Bin/libperl/$lModule.pm";
  require $lModulePath;

  my $lDataFile = "$FindBin::Bin/inputs/day$gDay.txt";
  (-e $lDataFile and -s $lDataFile) or die "No data file for day $gDay\n";

  open(my $lFH, '<', $lDataFile) or die "Failed to open $lDataFile\n";
  chomp(my @lDataLines = <$lFH>);
  close($lFH) or die "Failed to close $lDataFile\n";

  my $xoResult = $lModule->run(\@lDataLines);
  print "$xoResult\n";
  exit(0);
};

if ($EVAL_ERROR)
{
  print "Error: $EVAL_ERROR";
  exit(1);
}

sub Usage
{
  my ($xiError) = @_;
  if (defined($xiError))
  {
    print "Error: $xiError\n\n";
  }

  print <<EOF;
Usage: aoc.pl --day=<day> [--help|-h]

  --day       - Integer representing which day to run
  --help, -h  - Print this usage message
EOF

  exit(1);
}
