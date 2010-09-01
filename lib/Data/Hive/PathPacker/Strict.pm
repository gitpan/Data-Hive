use strict;
use warnings;
package Data::Hive::PathPacker::Strict;
BEGIN {
  $Data::Hive::PathPacker::Strict::VERSION = '1.005';
}
use base 'Data::Hive::PathPacker';
# ABSTRACT: a simple, strict path packer

use Carp ();


sub new {
  my ($class, $arg) = @_;
  $arg ||= {};

  my $guts = {
    separator => $arg->{separator} || '.',
  };

  return bless $guts => $class;
}

sub pack_path {
  my ($self, $path) = @_;

  my $sep     = $self->{separator};
  my @illegal = grep { /\Q$sep\E/ } @$path;

  Carp::confess("illegal hive path parts: @illegal") if @illegal;

  return join $sep, @$path;
}

sub unpack_path {
  my ($self, $str) = @_;

  my $sep = $self->{separator};
  return [ split /\Q$sep\E/, $str ];
}

1;

__END__
=pod

=head1 NAME

Data::Hive::PathPacker::Strict - a simple, strict path packer

=head1 VERSION

version 1.005

=head1 DESCRIPTION

The Strict path packer is the simplest useful implementation of
L<Data::Hive::PathPacker>.  It joins path parts together with a fixed string
and splits them apart on the same string.  If the fixed string occurs any path
part, an exception is thrown.

=head1 METHODS

=head2 new

  my $packer = Data::Hive::PathPacker::Strict->new( \%arg );

The only valid argument is C<separator>, which is the string used to join path
parts.  It defaults to a single period.

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

