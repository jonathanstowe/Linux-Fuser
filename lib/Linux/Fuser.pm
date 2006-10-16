#*****************************************************************************
#*                                                                           *
#*                          Gellyfish Software                               *
#*                                                                           *
#*                                                                           *
#*****************************************************************************
#*                                                                           *
#*      PROGRAM     :  Linux::Fuser                                          *
#*                                                                           *
#*      AUTHOR      :  JNS                                                   *
#*                                                                           *
#*      DESCRIPTION :  Provide an 'fuser' like facility in Perl              *
#*                                                                           *
#*                                                                           *
#*****************************************************************************
#*                                                                           *
#*      $Log: Fuser.pm,v $
#*      Revision 1.3  2005/03/17 19:16:39  jonathan
#*      * Updated README to reflect tested kernel versions
#*      * Reorganised the tests
#*      * Added Test::More as prerequisite
#*
#*      Revision 1.2  2001/11/07 07:09:52  gellyfish
#*      * Fixed thinko reported by Shawn Ferris
#*      * Added test
#*
#*      Revision 1.1  2001/03/05 08:13:19  gellyfish
#*      Initial revision
#*
#*                                                                           *
#*                                                                           *
#*****************************************************************************

package Linux::Fuser;

=head1 NAME

Linux::Fuser - Determine which processes have a file open

=head1 SYNOPSIS

  use Linux::Fuser;

  my $fuser = Linux::Fuser->new();

  my @procs = $fuser->fuser('foo');

  foreach my $proc ( @procs )
  {
    print $proc->pid(),"\t", $proc->user(),"\n",@{$proc->cmd()},"\n";
  }

=head1 DESCRIPTION

This module provides information similar to the Unix command 'fuser' about
which processes have a particular file open.  The way that this works is
highly unlikely to work on any other OS other than Linux and even then it
may not work on other than 2.2.* kernels.

It should also be borne in mind that this may not produce entirely accurate
results unless you are running the program as the Superuser as the module
will require access to files in /proc that may only be readable by their
owner.

=head2 METHODS

=over 4

=cut

use strict;

use vars qw(
  $VERSION
  @ISA
);

$VERSION = '1.4';

=item new

The constructor of the object. It takes no arguments and returns a blessed
reference suitable for calling the methods on.

=cut

sub new
{
    my ( $proto, @args ) = @_;

    my $class = ref($proto) || $proto;

    my $self = {};

    bless $self, $class;

    return $self;

}

=item fuser SCALAR $file

Given the name of a file it will return a list of Linux::Fuser::Procinfo
objects, one for each process that has the file open - this will be the
empty list if no processes have the file open or undef if the file doesnt
exist.

=cut

sub fuser
{
    my ( $self, $file, @args ) = @_;

    return () unless -f $file;

    my @procinfo = ();

    my ( $dev, $ino, @ostuff ) = stat($file);

    opendir PROC, '/proc' or die "Can't access /proc - $!\n";

    my @procs = grep /^\d+$/, readdir PROC;

    closedir PROC;

    foreach my $proc (@procs)
    {
        opendir FD, "/proc/$proc/fd" or next;

        my @fds = map { "/proc/$proc/fd/$_" } grep /^\d+$/, readdir FD;

        closedir FD;

        foreach my $fd (@fds)
        {
            if ( my @statinfo = stat $fd )
            {
                if ( ( $dev == $statinfo[0] ) && ( $ino == $statinfo[1] ) )
                {
                    my $user = getpwuid( ( lstat($fd) )[4] );

                    my @cmd = ('');

                    if ( open CMD, "/proc/$proc/cmdline" )
                    {
                        chomp( @cmd = <CMD> );
                    }

                    my $procinfo = {
                        pid  => $proc,
                        user => $user,
                        cmd  => \@cmd
                    };

                    bless $procinfo, 'Linux::Fuser::Procinfo';
                    push @procinfo, $procinfo;
                }
            }
        }
    }
    return @procinfo;
}

1;

package Linux::Fuser::Procinfo;

=back

=head2 PER PROCESS METHODS

The fuser() method will return a list of objects of type Linux::Fuser::Procinfo
which itself has methods to return information about the process.

=over 2

=item user

The login name of the user that started this process ( or more precisely
that owns the file descriptor that the file is open on ).

=item pid

The process id of the process that has the file open.

=item cmd

The command line of the program that opened the file.  This actually returns
a reference to an array containing the individual elements of the command
line.

=back


=cut

use strict;
use Carp;

use vars qw($AUTOLOAD);

sub AUTOLOAD
{
    my ( $self, @args ) = @_;

    no strict 'refs';

    ( my $method = $AUTOLOAD ) =~ s/.*://;

    return if $method eq 'DESTROY';

    if ( exists $self->{$method} )
    {
        *{$AUTOLOAD} = sub {
            my ( $self, @args ) = @_;
            return $self->{$method};
        };
    }
    else
    {
        my $pack = ref($self);
        croak "Can't find method $method via package $self";
    }

    goto &{$AUTOLOAD};

}

1;

__END__

=head2 EXPORT

None.

=head1 AUTHOR

Jonathan Stowe, E<lt>jns@gellyfish.comE<gt>

=head1 COPYRIGHT AND LICENSE

Please see the README file in the source distribution.

=head1 SEE ALSO

L<perl>. L<proc(5)>

=cut
