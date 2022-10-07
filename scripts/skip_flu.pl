sub
{
  use strict;
  my ($type, $comp, $attr, $en_decl_hash) = @_;
  
  if ($comp =~ m/^(?:\w+_B|TYPE_XFU|YXFUPT|TYPE_CFU|YCFUPT)$/o)
    {
      return 1;
    }

  return unless ($attr->{POINTER});

  if (my $en_decl = $en_decl_hash->{"F_$comp"})
    {
      my $stmt = &Fxtran::stmt ($en_decl);
      my ($tspec) = &Fxtran::F ('./_T-spec_', $stmt);  
      my ($tname) = &F ('./derived-T-spec/T-N/N/n/text()', $tspec);
      return 1 if ($tname =~ m/^FIELD_/o);
    }

  return 0;
}
