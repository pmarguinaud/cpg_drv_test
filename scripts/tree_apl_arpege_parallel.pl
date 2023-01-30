#!/home/gmap/mrpm/marguina/install/perl-5.32.0/bin/perl -w

package scan;

use strict;
use Data::Dumper;
use FileHandle;
use File::Basename;
use File::Find;

my %data;

sub slurp
{
  my ($file, $discard) = @_;

  unless (exists $data{$file})
    {
      my $fh = 'FileHandle'->new ("<$file");
      local $/ = undef;
      $data{$file} = <$fh>;
    }

  return delete ($data{$file}) if ($discard);

  return $data{$file};
}

sub scan
{
  shift;

  my %f2f;
  my %seen;
  
  my $wanted = sub
  {
    return unless (m/\.F90$/o);
    my $f = $File::Find::name;
    return if ($seen{&basename ($f)}++);
    my $code = &slurp ($f, 1);
    my ($s) = ($code =~ m/(?:MODULE|FUNCTION|PROGRAM|SUBROUTINE)[ ]+(\w+)/goms);
    return unless ($s);
    $s = uc ($s);
    $f2f{$s} = $f;
  };
  
  my @view = do { my $fh = 'FileHandle'->new ("<.gmkview"); my @v = <$fh>; chomp for (@v); @v };
  
  if (-f 'f2f.pl')
    {
      %f2f = %{ do ('./f2f.pl') };
      pop (@view) while (scalar (@view) > 1);
    }
  
  for my $view (@view)
    {
      &find ({wanted => $wanted, no_chdir => 1}, "src/$view/");
    }
  
  'FileHandle'->new (">f2f.pl")->print (&Dumper (\%f2f));

  return \%f2f;
}


my %call;

sub call
{
  shift;

  my $file = shift;

  unless (exists $call{$file})
    {
      my $code = &slurp ($file);
      my @code = grep { !/^\s*!/o } split (m/\n/o, $code);
      $code = join (";", @code);
      $call{$file} = [$code =~ m/\bCALL\s+(\w+)/goms];
    }

  return $call{$file};
}

my %size;

sub size
{
  shift;

  my $file = shift;
  
  die $file unless (-f $file);

  unless (exists $size{$file})
    {
      my @code = do { my $fh = 'FileHandle'->new ("<$file"); <$fh> };
      $size{$file} = scalar (@code);
    }

  return $size{$file};
}

my %openmp;

sub openmp
{
  shift;

  my $file = shift;
  
  die $file unless (-f $file);

  unless (exists $openmp{$file})
    {
      my @code = do { my $fh = 'FileHandle'->new ("<$file"); <$fh> };
      $openmp{$file} = scalar (grep { m/OMP PARALLEL/o } @code);
    }

  return $openmp{$file};
}

package main;

use strict;
use Data::Dumper;
use FileHandle;
use File::Basename;
use GraphViz2;

$ENV{PATH} = "/home/gmap/mrpm/marguina/install/graphviz-2.38.0/bin:$ENV{PATH}";

my $f2f = 'scan'->scan ();

my %g; # Graph
my %L; # Size
my %P;

my @q = @ARGV; # Routines to process

my %skip1 = map { ($_, 1) } qw (DR_HOOK ABOR1_SFX ABOR1 WRSCMR SC2PRG VERDISINT VEXP NEW_ADD_FIELD_3D ADD_FIELD_3D FMLOOK_LL
                                FMWRIT LES_MEAN_SUBGRID SECOND_MNH ABORT_SURF SURF_INQ SHIFT ABORT LFAECRR FLUSH LFAFER LFAECRI LFAOUV LFAECRC
                                LFAPRECR NEW_ADD_FIELD_2D ADD_FIELD_2D WRITEPROFILE WRITEMUSC WRITEPHYSIO CONVECT_SATMIXRATIO COMPUTE_FRAC_ICE
                                TRIDIA LFAPRECI PPP2DUST GET_LUOUT ALLOCATE DEALLOCATE PUT GET SAVE_INPUTS GET_FRAC_N DGEMM SGEMM);

sub add
{

# Add a routine to the graph

  my $name = shift;
  return if (exists $g{$name});
  $g{$name} ||= [];
  my $file = $f2f->{$name};

# Count line numbers

  unless ($file)
    {
      $L{$name} = '';
      return;
    }
  $L{$name} = 'scan'->size ($file);
  $P{$name} = 'scan'->openmp ($file);
}

for my $q (@q)
  {
    &add ($q);
  }


my @list = do { my $fh = 'FileHandle'->new ("<list"); <$fh> };
chomp for (@list);
my %list;

for (@list)
  {
    $list{&basename ($_)} = 1;
  }

my %seen;

while (my $name = shift (@q))
  {

    my $file = $f2f->{$name};

    next unless ($file);

    my @call = @{ 'scan'->call ($file) };
    
    @call = 
       grep { ! m/^(?:GSTAT|MPL_|JFH_)/o } 
       grep { ! $skip1{$_} } @call;

    for my $call (@call)
      {
        next if ($call =~ m/^(?:YLCPG_BNDS|RRTM_TAUMOL|SRTM_TAUMOL|COUPLING_SURF_ATM|ARO_GROUND_DIAG|DELETE_TEMPORARY|CREATE_TEMPORARY|ARO_GROUND_PARAM)/o);
        &add ($call);
        push @{ $g{$name} }, $call;
        push @q, $call unless ($seen{$call}++);
      }
    
  }


# Single link, even for multiple calls

while (my ($k, $v) = each (%g))
  {
    my %seen;
    @$v = grep { ! ($seen{$_}++) } grep { $g{$_} } @$v;
  }

my @root = keys (%g); # Never called by any other routine belonging to the graph

while (my ($k, $v) = each (%g))
  {
    my %v = map { ($_, 1) } @$v;
    @root = grep { ! $v{$_} } @root;
  }

sub color
{
  my $name = shift;
  if ($name =~ m/_PARALLEL/o)
    {
      return $list{$name} ? (style => 'filled', fillcolor => 'red') : ();
    }
  else
    {
      return $list{$name} ? (style => 'filled', fillcolor => 'pink') : ();
    }
}


my $root = join ('-', sort @root);

my $g = 'GraphViz2'->new (graph => {rankdir => 'LR', ordering => 'out'}, global => {rank => 'source'});
#my $g = 'GraphViz2'->new (graph => {rankdir => 'TB', ordering => 'out'}, global => {rank => 'source'});

while (my ($k, $v) = each (%g))
  {
    next if ($k =~ m/%/o); # Do not report method call
    my $lab = "$k\n$L{$k}";
    if ($P{$k})
      {
        $lab .= " ($P{$k})";
      }
    $g->add_node (name => $k, label => $lab, shape => 'box', &color ($k));
    for my $v (@$v)
      {   
        next if ($v =~ m/%/o); # Do not report method call
        $g->add_edge (from => $k, to => $v);
      }   
  }

$g->run (format => 'svg', output_file => "$root.svg");


