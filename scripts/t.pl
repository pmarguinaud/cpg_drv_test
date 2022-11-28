#!/usr/bin/perl -w
#
use strict;
use FileHandle;
use FindBin qw ($Bin);
use lib $Bin;
use Fxtran;
use File::Basename;
use Data::Dumper;
use List::MoreUtils qw (uniq);


my ($f1, $f2) = @ARGV;

my $d1 = &parse (location => $f1, fopts => [qw (-line-length 512)]);
my $d2 = &parse (location => $f2, fopts => [qw (-line-length 512)]);

my ($name) = &F ('./object/file/program-unit/subroutine-stmt/subroutine-N', $d2, 1);
my @darg = &F ('./object/file/program-unit/subroutine-stmt/dummy-arg-LT/arg-N', $d2);

my %decl;

for my $darg (@darg)
  {
    my ($decl) = &F ('.//T-decl-stmt[.//EN-decl[string(EN-N)="?"]]', $darg->textContent, $d2);
    $decl{$darg->textContent} = $decl;
  }


my @call = &F ('.//call-stmt[string(procedure-designator)="?"]', $name, $d1);

for my $call (@call)
  {
    print $call->textContent, "\n";
    my @aarg = &F ('./arg-spec/arg', $call);

    my $i = 0;
    for my $aarg (@aarg)
      {
        my @n = $aarg->childNodes (); 
        my ($darg, $expr);
        if (scalar (@n) == 1)
          {
            ($darg, $expr) = ($darg[$i], $n[0]);
          }
        elsif (scalar (@n) == 3)
          {
            ($darg, $expr) = ($n[0], $n[2]);
          }
        else
          {
            die &Dumper ([$call->textContent, \@n])  if (scalar (@n) > 1);
          }
        my ($optional) = &F ('.//attribute[string(attribute-N)="OPTIONAL"]', $decl{$darg->textContent});
        printf (" %s   %-40s = %s\n", $optional ? '*' : ' ', $darg->textContent, $expr->textContent);
        $i++;
      }

    print '-' x 80, "\n";
  }






