use strict;
use warnings;
package Data::Hive::Store::Hash;
BEGIN {
  $Data::Hive::Store::Hash::VERSION = '1.006';
}
use base 'Data::Hive::Store';
# ABSTRACT: store a hive in a flat hashref


sub new {
  my ($class, $href, $arg) = @_;
  $href = {} unless $href;
  $arg  = {} unless $arg;

  my $guts = {
    store       => $href,
    path_packer => $arg->{path_packer} || do {
      require Data::Hive::PathPacker::Strict;
      Data::Hive::PathPacker::Strict->new;
    },
  };

  return bless $guts => $class;
}


sub hash_store  { $_[0]->{store} }
sub path_packer { $_[0]->{path_packer} }

sub get {
  my ($self, $path) = @_;
  return $self->hash_store->{ $self->name($path) };
}

sub set {
  my ($self, $path, $value) = @_;
  $self->hash_store->{ $self->name($path) } = $value;
}

sub name {
  my ($self, $path) = @_;
  $self->path_packer->pack_path($path);
}

sub exists {
  my ($self, $path) = @_;
  exists $self->hash_store->{ $self->name($path) };
}  

sub delete {
  my ($self, $path) = @_;

  delete $self->hash_store->{ $self->name($path) };
}

sub keys {
  my ($self, $path) = @_;

  my $method = $self->{method};
  my @names  = keys %{ $self->hash_store };

  my %is_key;

  PATH: for my $name (@names) {
    my $this_path = $self->path_packer->unpack_path($name);

    next unless @$this_path > @$path;

    for my $i (0 .. $#$path) {
      next PATH unless $this_path->[$i] eq $path->[$i];
    }

    $is_key{ $this_path->[ $#$path + 1 ] } = 1;
  }

  return keys %is_key;
}

1;

__END__
=pod

=head1 NAME

Data::Hive::Store::Hash - store a hive in a flat hashref

=head1 VERSION

version 1.006

=head1 DESCRIPTION

This is a simple store, primarily for testing, that will store hives in a flat
hashref.  Paths are packed into strings and used as keys.  The structure does
not recurse -- for that, see L<Data::Hive::Store::Hash::Nested>.

So, we could do this:

  my $href = {};

  my $hive = Data::Hive->NEW({
    store_class => 'Hash',
    store_args  => [ $href ],
  });

  $hive->foo->SET(1);
  $hive->foo->bar->baz->SET(2);

We would end up with C<$href> containing something like:

  {
    foo => 1,
    'foo.bar.baz' => 2
  }

=head1 METHODS

=head2 new

  my $store = Data::Hive::Store::Hash->new(\%hash, \%arg);

The only argument expected for C<new> is a hashref, which is the hashref in
which hive entries are stored.

If no hashref is provided, a new, empty hashref will be used.

The extra arguments may include:

=over 4

=item path_packer

A L<Data::Hive::PathPacker>-like object used to convert between paths
(arrayrefs) and hash keys.

=back

=head2 hash_store

This method returns the hashref in which things are being used.  You should not
alter its contents!

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

