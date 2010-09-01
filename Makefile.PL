
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'convenient access to hierarchical data',
  'AUTHOR' => 'Hans Dieter Pearcey <hdp@cpan.org>, Ricardo Signes <rjbs@cpan.org>',
  'BUILD_REQUIRES' => {
    'Try::Tiny' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Data-Hive',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Data::Hive',
  'PREREQ_PM' => {
    'Carp' => '0',
    'Test::More' => '0.94',
    'overload' => '0'
  },
  'VERSION' => '1.002',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



