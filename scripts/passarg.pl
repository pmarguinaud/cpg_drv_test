#!/home/gmap/mrpm/marguina/install/perl-5.32.0/bin/perl -w
#
use strict;
use FindBin qw ($Bin);
use Data::Dumper;
use FileHandle;
use File::Basename;
use File::Copy;
use lib $Bin;
use Fxtran;

sub var2dum
{
  my $v = shift;
  for ($v)
    {
      s/^L/LD/o && return $v;
      s/^N/K/o && return $v;
      s/^([RT])/P$1/o && return $v;
    }
  die $v;
}

sub var2typ
{
  my $v = shift;
  for ($v)
    {
      m/^L/o && return 'LOGICAL';
      m/^N/o && return 'INTEGER (KIND=JPIM)';
      m/^[RT]/o && return 'REAL (KIND=JPRB)';
    }
  die;
}

my @view = do { my $fh = 'FileHandle'->new ("<.gmkview"); my @v = <$fh>; chomp for (@v); @v };

sub local
{
  my $f = shift;
  my $h = "src/local/$f";
  return $h if (-f $h);
  for my $view (@view[1..$#view])
    {
      my $g = "src/$view/$f";
      if (-f $g)
        {
          &copy ($g, $h);
          return $h;
        }
    }
  die $f;
}

my ($F90, $mod) = @ARGV;

my $d = &Fxtran::fxtran (location => $F90, fopts => [qw (-line-length 400)]);

my ($use_mod) = &F ('.//use-stmt[string(module-N)="?"]', $mod, $d);

my ($pu) = &F ('ancestor::program-unit', $use_mod);

my @var = &F ('.//use-N', $use_mod, 1);
$use_mod->unbindNode ();

my ($dal) = &F ('.//dummy-arg-LT', $pu);
my ($decl) = &F ('.//T-decl-stmt', $pu);

my ($sub) = &F ('.//subroutine-N', $pu, 1);

@var = reverse (sort @var);

for my $var (@var)
  {
    my $dum = &var2dum ($var);
    $dal->insertBefore (&t (', '), $dal->firstChild);
    $dal->insertBefore (&n ("<arg-N><N><n>$dum</n></N></arg-N>"), $dal->firstChild);
    my $typ = &var2typ ($var);
    $decl->parentNode->insertBefore (&s ("$typ, INTENT (IN) :: $dum"), $decl);
    $decl->parentNode->insertBefore (&t ("\n"), $decl);

    my @expr = &F ('.//named-E[string(N)="?"]/N/n/text()', $var, $pu);

    for my $expr (@expr)
      {
        $expr->setData ($dum);
      }

  }

'FileHandle'->new (">$F90.new")->print ($d->textContent);

my $c2f = do './c2f.pl';

my @f = sort keys (%{ $c2f->{$sub} });

for my $f (@f)
  {
    my $f = &local ($f);

    my $d = &Fxtran::fxtran (location => $f, fopts => [qw (-line-length 400)]);

    if (my ($ydcpg_opts) = &F ('.//arg-N[string(.)="YDCPG_OPTS"]', $d))
      {
        my @call = &F ('.//call-stmt[string(procedure-designator)="?"]', $sub, $d);
        for my $call (@call)
          {
            my ($argspec) = &F ('./arg-spec', $call);
            for my $var (@var)
              {
                $argspec->insertBefore (&t (', '), $argspec->firstChild);
                $argspec->insertBefore (&n ('<arg>' . &e ("YDCPG_OPTS%$var") . '</arg>'), $argspec->firstChild);
              }
          }
      }
   else
      {
        if (my ($use) = &F ('.//use-stmt[string(module-N)="?"]', $mod, $d))
          {
            my ($rlt) = &F ('./rename-LT', $use);
            for my $var (@var)
              {
                next if (&F ('.//use-N[string(.)="?"]', $var, $rlt));
                $rlt->appendChild (&t (', '));
                $rlt->appendChild (&n ("<rename><use-N><N><n>$var</n></N></use-N></rename>"));
              }
          }
        else
          {
            my @use = &F ('.//use-stmt', $d);
            my ($use0) = $use[-1];
            $use0->parentNode->insertAfter ($use_mod->cloneNode (1), $use0);
            $use0->parentNode->insertAfter (&t ("\n"), $use0);
          }
        my @call = &F ('.//call-stmt[string(procedure-designator)="?"]', $sub, $d);
        for my $call (@call)
          {
            my ($argspec) = &F ('./arg-spec', $call);
            for my $var (@var)
              {
                $argspec->insertBefore (&t (', '), $argspec->firstChild);
                $argspec->insertBefore (&n ('<arg>' . &e ($var) . '</arg>'), $argspec->firstChild);
              }
          }
      }
      
    'FileHandle'->new (">$f.new")->print ($d->textContent);


  }


