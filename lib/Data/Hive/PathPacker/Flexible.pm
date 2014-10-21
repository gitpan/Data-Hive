use strict;
use warnings;
package Data::Hive::PathPacker::Flexible;
BEGIN {
  $Data::Hive::PathPacker::Flexible::VERSION = '1.004';
}
use base 'Data::Hive::PathPacker';
# ABSTRACT: a path packer that can be customized with callbacks


sub new {
  my ($class, $arg) = @_;
  $arg ||= {};

  my $guts = {
    separator => $arg->{separator} || '.',

    escape    => $arg->{escape}   || sub  {
      my ($self, $str) = @_;
      $str =~ s/([^a-z0-9_])/sprintf("%%%x", ord($1))/gie;
      return $str;
    },

    unescape  => $arg->{unescape} || sub {
      my ($self, $str) = @_;
      $str =~ s/%([0-9a-f]{2})/chr(hex($1))/ge;
      return $str;
    },

    join      => $arg->{join}  || sub { join $_[0]{separator}, @{$_[1]} },
    split     => $arg->{split} || sub { split /\Q$_[0]{separator}/, $_[1] },
  };

  return bless $guts => $class;
}

sub pack_path {
  my ($self, $path) = @_;

  my $escape = $self->{escape};
  my $join   = $self->{join};

  return $self->$join([ map {; $self->$escape($_) } @$path ]);
}

sub unpack_path {
  my ($self, $str) = @_;

  my $split    = $self->{split};
  my $unescape = $self->{unescape};

  return [ map {; $self->$unescape($_) } $self->$split($str) ];
}

1;

__END__
=pod

=head1 NAME

Data::Hive::PathPacker::Flexible - a path packer that can be customized with callbacks

=head1 VERSION

version 1.004

=head1 DESCRIPTION

This class provides the Data::Hive::PathPacker interface, and the way in which
paths are packed and unpacked can be defined by callbacks set during
initialization.

=head1 METHODS

=head2 new

  my $path_packer = Data::Hive::PathPacker::Flexible->new( \%arg );

The valid arguments are:

=over 4

=item escape and unescape

These coderefs are used to escape and path parts so that they can be split and
joined without ambiguity.  The callbacks will be called like this:

  my $result = do {
    local $_ = $path_part;
    $store->$callback( $path_part );
  }

The default escape routine uses URI-like encoding on non-word characters.

=item join, split, and separator

The C<join> coderef is used to join pre-escaped path parts.  C<split> is used
to split up a complete name before unescaping the parts.

By default, they will use a simple perl join and split on the character given
in the C<separator> option.

=back

=head1 AUTHORS

=over 4

=item *

Hans Dieter Pearcey <hdp@cpan.org>

=item *

Ricardo Signes <rjbs@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2006 by Hans Dieter Pearcey.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

