use strict;
use warnings;
package Data::Hive::Store;
BEGIN {
  $Data::Hive::Store::VERSION = '0.054';
}
# ABSTRACT: a backend storage driver for Data::Hive

use Carp ();


BEGIN {
  for my $meth (qw(get set name exists delete keys)) {
    no strict 'refs';
    *$meth = sub { Carp::croak("$_[0] does not implement $meth") };
  }
}

1;

__END__
=pod

=head1 NAME

Data::Hive::Store - a backend storage driver for Data::Hive

=head1 VERSION

version 0.054

=head1 DESCRIPTION

Data::Hive::Store is a generic interface to a backend store
for Data::Hive.

=head1 METHODS

All methods are passed at least a 'path' (arrayref of namespace pieces).  Store
classes exist to operate on the entities found at named paths.

=head2 get

  print $store->get(\@path, \%opt);

Return the resource represented by the given path.

=head2 set

  $store->set(\@path, $value, \%opt);

Analogous to C<< get >>.

=head2 name

  print $store->name(\@path, \%opt);

Return a store-specific name for the given path.  This is primarily useful for
stores that may be accessed independently of the hive.

=head2 exists

  if ($store->exists(\@path, \%opt)) { ... }

Returns true if the given path exists in the store.

=head2 delete

  $store->delete(\@path, \%opt);

Delete the given path from the store.  Return the previous value, if any.

=head2 keys

  my @keys = $store->keys(\@path, \%opt);

This returns a list of next-level path elements that exist.  For example, given
a hive with values for the following paths:

  foo
  foo/bar
  foo/bar/baz
  foo/xyz/abc
  foo/xyz/def
  foo/123

This shows the expected results:

  keys of      | returns
  -------------+------------
  foo          | bar, xyz, 123
  foo/bar      | baz
  foo/bar/baz  |
  foo/xyz      | abc, def
  foo/123      |

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

