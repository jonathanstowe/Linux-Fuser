
use Test;
BEGIN { plan tests => 3 };
use Linux::Fuser;
ok(1);


eval 
{
   my $f = Linux::Fuser->new();

   open(F,">$$.tmp");
   my @procs = $f->fuser("$$.tmp");
   
   foreach $proc ( @procs )
   {
      my $pid  = $proc->pid();
      my $user = $proc->user(),"\n";

      die "" if ( $pid != $$ );
   }

   close F;
};

if ( $@)
{
  ok(0);
}
else
{
  ok(2);
}

my $f = Linux::Fuser->new();

eval
{
   my @procs = $f->fuser('ThIsHaDbEtTeRnOtExIsT');

   if ( @procs )
   {
     ok(0);
   }
   else
   {
     ok(3);
   }
};

if ( $@ )
{
   ok(0);
}

END 
{
   unlink "$$.tmp";
};

