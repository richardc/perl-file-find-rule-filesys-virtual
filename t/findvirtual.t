#!perl -w
use strict;
use Test::More tests => 1;
use File::Find::Rule;
use File::Find::Rule::Filesys::Virtual;
use Filesys::Virtual::Plain;
use Cwd;

my $virtual = Filesys::Virtual::Plain->new({
    root_path => getcwd,
    cwd       => '/',
    root      => '/',
});

sub new_real { File::Find::Rule->new }
sub new_virt { File::Find::Rule::Filesys::Virtual->new->virtual( $virtual ) }

isa_ok( new_real, "File::Find::Rule" );
isa_ok( new_virt, "File::Find::Rule::Filesys::Virtual" );
is_deeply( [ new_virt->file->in( 't' ) ],
           [ new_real->file->in( 't' ) ],
           "files in t/" );

is_deeply( [ new_virt->size('>600')->in( 't' ) ],
           [ new_real->size('>600')->in( 't' ) ],
           "stat in t/" );
