
use Test::More tests => 6;
use_ok('Linux::Fuser');


eval 
{
   my $f = Linux::Fuser->new();

   open(F,">$$.tmp");
   my @procs = $f->fuser("$$.tmp");
   
   ok(@procs,"The file has users");
   my ($proc ) =   @procs;
   my $pid  = $proc->pid();
   ok($pid = $$,"Got the right PID");
   my $user = $proc->user();
   ok($user eq scalar getpwuid($>), "And I'm the right user");
   close F;
};
ok(!$@, "Works for existing file");

my $f = Linux::Fuser->new();

eval
{
   my @procs = $f->fuser('ThIsHaDbEtTeRnOtExIsT');

   die "Whoah!" if ( @procs );
};

ok(!$@,"Non-existent file");

END 
{
   unlink "$$.tmp";
};

