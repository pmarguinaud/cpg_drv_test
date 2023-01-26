#!/usr/bin/perl -w
#
use strict;
use FileHandle;
use Data::Dumper;
use File::Basename;
use Storable;
use FindBin qw ($Bin);
use lib "/home/gmap/mrpm/marguina/fxtran-acdc/lib";
use lib "$Bin/../lib";

use Common;

my %T;

for my $f (<types/*.pl>)
  {
    my $T = &basename ($f, qw (.pl));
    $T{$T} = do ("./$f");
  }


for my $T (keys (%T))
  {
    if (my $super = $T{$T}{super})
      {
        $T{$T}{super} = $T{$super};
      }
    for my $v (values (%{ $T{$T}{comp} }))
      {
        next unless (my $ref = ref ($v));
        if ($ref eq 'SCALAR')
          {
            my $t = $$v;
            $v = $T{$t};
          }
      }
  }

my %TT;

while (my ($t, $h) = each (%T))
  {
    my %h;
    for (my $hh = $h; $hh; $hh = $hh->{super})
      {
        while (my ($k, $v) = each (%{ $hh->{comp} }))
          {
            next unless (my $ref = ref ($v));
            if ($ref eq 'HASH')
              {
                $TT{$v->{name}} ||= {};
                $h{$k} = $TT{$v->{name}};
              }
            elsif ($ref eq 'ARRAY')
              {
                $h{$k} = $v;
              }
          }
      }
    $TT{$t} ||= {};
    %{ $TT{$t} } = %h;
  }

#print &Dumper (\%TT);

sub walk
{
  my ($p, $h, $r) = @_;

  if (ref ($h) eq 'ARRAY')
    {
      my ($k) = ($p =~ m/%(\w+)$/o);
      $r->{$p} = $h->[2] . ' :: ' . $k . '(' . join (',', (':') x $h->[1]) . ')';
    }
  elsif (ref ($h) eq 'HASH')
    {
      for my $k (sort keys (%$h))
        {
          &walk ($p . '%' . $k, $h->{$k}, $r);
        }
    }

}

my %r;

for my $t (sort keys (%TT))
  {
    &walk ($t, $TT{$t}, \%r);
  }


local $Data::Dumper::Terse = 1;
local $Data::Dumper::Sortkeys = 1;
'FileHandle'->new ('>h.pl')->print (&Dumper (\%r));


