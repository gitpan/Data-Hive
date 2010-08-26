use strict;
use warnings;
package Data::Hive::Store::Hash;
BEGIN {
  $Data::Hive::Store::Hash::VERSION = '0.054';
}
# ABSTRACT: store a hive in nested hashrefs


sub new {
  my ($class, $hash) = @_;
  return bless \$hash => $class;
}


sub _die {
  require Carp::Clan;
  Carp::Clan->import('^Data::Hive($|::)');
  croak(shift);
}

my $BREAK = "BREAK\n";
my $LAST = "LAST\n";

sub _descend {
  my ($self, $path, $arg) = @_;
  my @path = @$path;
  $arg ||= {};
  $arg->{step} or die "step is required";
  $arg->{cond} ||= sub { @{ shift() } };
  $arg->{end}  ||= sub { $_[0] };

  my $node = $$self;
  while ($arg->{cond}->(\@path)) {
    my $seg = shift @path;

    {
      local $SIG{__DIE__};
      eval { $arg->{step}->($seg, $node, \@path) };
    }

    return if $@ and $@ eq $BREAK;
    die $@ if $@;
    $node = $node->{$seg} ||= {};
  }

  return $arg->{end}->($node, \@path);
}

sub get {
  my ($self, $path) = @_;
  return $self->_descend(
    $path, {
      step => sub {
        my ($seg, $node) = @_;
        if (defined $node and not ref $node) {
          _die("can't get key '$seg' of non-ref value '$node'");
        }
        die $BREAK unless exists $node->{$seg};
      }
    }
  );
}


sub set {
  my ($self, $path, $value) = @_;
  return $self->_descend(
    $path, {
      step => sub {
        my ($seg, $node, $path) = @_;
        if (exists $node->{$seg} and not ref $node->{$seg}) {
          _die("can't overwrite existing non-ref value: '$node->{$seg}'");
        }
      },
      cond => sub { @{ shift() } > 1 },
      end  => sub {
        my ($node, $path) = @_;
        $node->{$path->[0]} = $value;
      },
    },
  );
}


sub name {
  my ($self, $path) = @_;
  return join '->', '$STORE', map { "{'$_'}" } @$path;
}


sub exists {
  my ($self, $path) = @_;
  return $self->_descend(
    $path, { 
      step => sub {
        my ($seg, $node) = @_;
        die $BREAK unless exists $node->{$seg};
      },
    },
  );
}  


sub delete {
  my ($self, $path) = @_;
  return $self->_descend(
    $path, {
      step => sub {
        my ($seg, $node) = @_;
        die $BREAK unless exists $node->{$seg};
      },
      cond => sub { @{ shift() } > 1 },
      end  => sub {
        my ($node, $path) = @_;
        delete $node->{$path->[0]};
      },
    },
  );
}

1;

__END__
=pod

=head1 NAME

Data::Hive::Store::Hash - store a hive in nested hashrefs

=head1 VERSION

version 0.054

=head1 DESCRIPTION

Simple hash store for Data::Hive.

=head1 METHODS

=head2 new

  my $store = Data::Hive::Store::Hash->new(\%hash);

Takes a hashref to use as the store.

=head2 get

Use given C<< \@path >> as nesting keys in the hashref store.

=head2 set

See C<L</get>>.  Dies if you try to set a key underneath an existing
non-hashref key, e.g.:

  $hash = { foo => 1 };
  $store->set([ 'foo', 'bar' ], 2); # dies

=head2 name

Returns a string, potentially suitable for eval-ing, describing a hash
dereference of a variable called C<< $STORE >>.

  "$STORE->{foo}->{bar}"

This is probably not very useful.

=head2 exists

Descend the hash and return false if any of the path's parts do not exist, or
true if they all do.

=head2 delete

Descend the hash and delete the given path.  Only deletes the leaf.

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

