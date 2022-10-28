#!/home/gmap/mrpm/marguina/install/perl-5.32.0/bin/perl -w
#
use strict;
use FindBin qw ($Bin);
use Data::Dumper;
use FileHandle;
use File::Basename;
use List::MoreUtils qw (uniq all);
use lib $Bin;
use Fxtran;


my $F90 = shift;

my $doc = &Fxtran::fxtran (location => $F90, fopts => [qw (-line-length 300)]);

my ($contains) = &F ('./object/file/program-unit/contains-stmt', $doc);

exit (0) unless ($contains);

my @pu = &F ('following-sibling::program-unit', $contains);


for my $pu (@pu)
  {
    $pu->unbindNode ();
  }

my @contains = &F ('//T-construct/contains-stmt', $doc);

for my $contains (@contains)
  {
    my @pr = &F ('following-sibling::component-decl-stmt|following-sibling::procedure-stmt|following-sibling::final-stmt', $contains);
    for my $pr (@pr)
      {
        $pr->unbindNode ();
      }
  
  }

rename ($F90, "$F90.old");

'FileHandle'->new (">$F90")->print ($doc->textContent);
