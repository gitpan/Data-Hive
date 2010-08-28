use strict;
use warnings;
package Data::Hive::Store::Param;
BEGIN {
  $Data::Hive::Store::Param::VERSION = '1.000';
}
# ABSTRACT: CGI::param-like store for Data::Hive

use URI::Escape ();


sub _escape {
  my ($self, $str) = @_;
  my $escape = $self->{escape} or return $str;
  $str =~ s/([\Q$escape\E%])/sprintf("%%%x", ord($1))/ge;
  return $str;
}

sub _path {
  my ($self, $path) = @_;
  return join $self->{separator}, map { $self->_escape($_) } @$path;
}

sub new {
  my ($class, $obj, $arg) = @_;
  $arg              ||= {};
  $arg->{escape}    ||= $arg->{separator} || '.';
  $arg->{separator} ||= substr($arg->{escape}, 0, 1);
  $arg->{method}    ||= 'param';
  $arg->{exists}    ||= sub { exists $obj->{shift()} };
  $arg->{delete}    ||= sub { delete $obj->{shift()} };
  $arg->{obj}         = $obj;
  return bless { %$arg } => $class;
}

sub _param {
  my $self = shift;
  my $meth = $self->{method};
  my $path = $self->_path(shift);
  return $self->{obj}->$meth($path, @_);
}

sub get {
  my ($self, $path) = @_;
  return $self->_param($path);
}

sub set {
  my ($self, $path, $val) = @_;
  return $self->_param($path => $val);
}
 
sub name {
  my ($self, $path) = @_;
  return $self->_path($path);
}

sub exists {
  my ($self, $path) = @_;
  my $code = $self->{exists};
  my $key = $self->_path($path);
  return ref($code) ? $code->($key) : $self->{obj}->$code($key);
}

sub delete {
  my ($self, $path) = @_;
  my $code = $self->{delete};
  my $key = $self->_path($path);

  return $self->{obj}->$code($key);
}

sub keys {
  my ($self, $path) = @_;

  my $method = $self->{method};
  my @names  = $self->{obj}->$method;

  my $name = $self->_path($path);

  my $sep = $self->{separator};

  my $start = length $name ? "$name$sep" : q{};
  my %seen  = map { /\A\Q$start\E(.+?)(\z|\Q$sep\E)/ ? ($1 => 1) : () } @names;

  my @keys = map { URI::Escape::uri_unescape($_) } keys %seen;
  return @keys;
}


1;

__END__
=pod

=head1 NAME

Data::Hive::Store::Param - CGI::param-like store for Data::Hive

=head1 VERSION

version 1.000

=head1 DESCRIPTION

This hive store will soon be overhauled.

Basically, it expects to access a hive in an object with CGI's C<param> method,
or the numerous other things with that interface.

=head1 METHODS

=head2 new

  # use default method name 'param'
  my $store = Data::Hive::Store::Param->new($obj);

  # use different method name 'info'
  my $store = Data::Hive::Store::Param->new($obj, { method => 'info' });

  # escape certain characters in keys
  my $store = Data::Hive::Store::Param->new($obj, { escape => './!' });

Return a new Param store.

Several interesting arguments can be passed in a hashref after the first
(mandatory) object argument.

=over 4

=item method

Use a different method name on the object (default is 'param').

=item escape

List of characters to escape (via URI encoding) in keys.

Defaults to the C<< separator >>.

=item separator

String to join path segments together with; defaults to either the first
character of the C<< escape >> option (if given) or '.'.

=item exists

Coderef that describes how to see if a given parameter name (C<< separator
>>-joined path) exists.  The default is to treat the object like a hashref and
look inside it.

=item delete

Coderef that describes how to delete a given parameter name.  The default is to
treat the object like a hashref and call C<delete> on it.

=back

=head1 BUGS

The interaction between escapes and separators is not very well formalized or
tested.  If you change things much, you'll probably be frustrated.

Fixes and/or tests would be lovely.

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

