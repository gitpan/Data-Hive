use strict;
use warnings;
package Data::Hive;
BEGIN {
  $Data::Hive::VERSION = '0.054';
}
# ABSTRACT: convenient access to hierarchical data

use Carp ();


sub NEW {
  my ($class, $arg) = @_;
  $arg ||= {};

  my @path = @{ $arg->{path} || [] };

  my $self = bless { path => \@path } => ref($class) || $class;

  if ($arg->{store_class} and $arg->{store_args}) {
    die "don't use 'store' with 'store_class' and 'store_args'"
      if $arg->{store};

    $arg->{store_class} = "Data::Hive::Store::$arg->{store_class}"
      unless $arg->{store_class} =~ s/^[+=]//;

    $self->{store} = $arg->{store_class}->new(@{ $arg->{store_args} });
  } else {
    $self->{store} = $arg->{store};
  }

  return $self;
}


use overload (
  q{""}    => 'GETSTR',
  q{0+}    => 'GETNUM',
  fallback => 1,
);

sub GET {
  my ($self, $default) = @_;
  my $value = $self->{store}->get($self->{path});
  return defined $value ? $value : $default;
}

sub GETNUM { shift->GET(@_) || 0 }

sub GETSTR {
  my $rv = shift->GET(@_);
  return defined($rv) ? $rv : '';
}


sub SET {
  my $self = shift;
  return $self->{store}->set($self->{path}, @_);
}


sub NAME {
  my $self = shift;
  return $self->{store}->name($self->{path});
}


sub ITEM {
  my ($self, $key) = @_;
  return $self->NEW({
    %$self,
    path => [ @{$self->{path}}, $key ],
  });
}

sub AUTOLOAD {
  my $self = shift;
  our $AUTOLOAD;

  (my $method = $AUTOLOAD) =~ s/.*:://;
  die "AUTOLOAD for '$method' called on non-object" unless ref $self;

  return if $method eq 'DESTROY';

  if ($method =~ /^[A-Z]+$/) {
    Carp::croak("all-caps method names are reserved: '$method'");
  }

  return $self->ITEM($method);
}


sub EXISTS {
  my $self = shift;
  return $self->{store}->exists($self->{path});
}


sub DELETE {
  my $self = shift;
  return $self->{store}->delete($self->{path});
}

1;

__END__
=pod

=head1 NAME

Data::Hive - convenient access to hierarchical data

=head1 VERSION

version 0.054

=head1 SYNOPSIS

  use Data::Hive;

  my $hive = Data::Hive->NEW(\%arg);
  print $hive->foo->bar->baz;
  $hive->foo->bar->quux->SET(17);

=head1 METHODS

Several methods are thin wrappers around required modules in
Data::Hive::Store subclasses.  These methods all basically
call a method on the store with the same (but lowercased)
name and pass it the hive's path:

=over 4

=item *

EXISTS

=item *

GET

=item *

SET

=item *

NAME

=item *

DELETE

=back

=head2 NEW

arguments:

=over 4

=item store

A Data::Hive::Store object, or an object that implements the required methods.
Those are:

=over 4

=item *

C<get>

=item *

C<set>

=item *

C<name>

=item *

C<exists>

=item *

C<delete>

=back

=item store_class

Class to instantiate C<< $store >> from.  The classname will have
C<Data::Hive::Store::> prepended; to avoid this, prefix it with a '='
(C<=My::Store>).  Mutually exclusive with the C<< store >> option.

A plus sign can be used instead of an equal sign, for historical reasons.

=item store_args

Arguments to instantiate C<< $store >> with.  Mutually exclusive with the C<<
store >> option.

=back

=head2 GET

Retrieve the value represented by this object's path from the store.  If an
argument is passed, and the value of the entry is undef, the passed value is
returned.

  $hive->some->path->GET(10);

The above will either returned the stored, defined value or 10.

=head2 GETNUM

=head2 GETSTR

Soley for Perl 5.6.1 compatability, where returning undef from overloaded
numification/stringification can cause a segfault.

=head2 SET

  $hive->some->path->SET($val);

Set this path's value in the store.

=head2 NAME

Returns a textual representation of this hive's path.
Store-dependent.

=head2 ITEM

  $hive->ITEM('foo');

Return a child of this hive.  Useful for path segments whose names are not
valid Perl method names.

=head2 EXISTS

  if ($hive->foo->bar->EXISTS) { ... }

Return true if the value represented by this hive exists in
the store.

=head2 DELETE

  $hive->foo->bar->DELETE;

Delete the value represented by this hive from the store.  Returns the previous
value, if any.

Throw an exception if the given store can't delete items for some reason.

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

