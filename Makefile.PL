use ExtUtils::MakeMaker;

if ( $^O !~ /linux/i )
{
   print <<EIEIO;

  Whoah! You brave soul :)

  This module is extremely unlikely to work on any other OS than Linux.

  However if you do find that it works please tell the author so the
  documentation and perhaps even the name of the module can be updated.

EIEIO
}

WriteMakefile(
    'NAME'		=> 'Linux::Fuser',
    'VERSION_FROM'	=> 'lib/Linux/Fuser.pm',
    'PREREQ_PM'		=> {'Test::More' => undef},
    'EXE_FILES'      => ['examples/pfuser'],
    ($] >= 5.005 ?  
      (
       AUTHOR     => 'Jonathan Stowe <jns@gellyfish.com>') : ()),
);
