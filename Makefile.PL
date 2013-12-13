
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "convenient access to hierarchical data",
  "AUTHOR" => "Hans Dieter Pearcey <hdp\@cpan.org>, Ricardo Signes <rjbs\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Data-Hive",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Data::Hive",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Test::More" => "0.96",
    "base" => 0,
    "overload" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "Test::More" => "0.96",
    "Try::Tiny" => 0
  },
  "VERSION" => "1.011",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Carp" => 0,
  "Test::More" => "0.96",
  "Try::Tiny" => 0,
  "base" => 0,
  "overload" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



