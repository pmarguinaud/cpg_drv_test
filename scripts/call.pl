#!/home/gmap/mrpm/marguina/install/perl-5.32.0/bin/perl -w
#
use strict;
use FindBin qw ($Bin);
use Data::Dumper;
use FileHandle;
use File::Basename;
use File::Find;
use lib $Bin;

sub slurp
{
  my $file = shift;
  my $fh = 'FileHandle'->new ("<$file");
  local $/ = undef;
  my $data = <$fh>;
  return $data;
}

my %c2f;
my %seen;

sub wanted
{
  return unless (m/\.F90$/o);
  my $f = $File::Find::name;
  return if ($seen{&basename ($f)}++);
  my $code = &slurp ($f);
  my @c = ($code =~ m/\n\s*CALL\s+(\w+)/goms);

  $f =~ s,^src/\w+/,,o;

  for my $c (@c)
    {
      $c = uc ($c);
      $c2f{$c}{$f}++;
    }
}

my @view = do { my $fh = 'FileHandle'->new ("<.gmkview"); my @v = <$fh>; chomp for (@v); @v };

for my $view (@view)
  {
    &find ({wanted => \&wanted, no_chdir => 1}, "src/$view/");
  }

'FileHandle'->new (">c2f.pl")->print (&Dumper (\%c2f));


