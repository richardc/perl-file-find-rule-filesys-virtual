package File::Find::Rule::Filesys::Virtual;
use strict;
use warnings;
use base qw( File::Find::Rule );
our $VERSION = 1.21;

=head1 NAME

File::Find::Rule::Filesys::Virtual - File::Find::Rule adapted to Filesys::Virtual

=head1 SYNOPSIS

 use File::Find::Rule::Filesys::Virtual;

=head1 DESCRIPTION

=cut


BEGIN { *_force_object = \&File::Find::Rule::_force_object }
sub virtual {
    my $self = _force_object shift;
    $self->{_virtual} = shift;
    return $self;
}

our %X_tests;
*X_tests = \%File::Find::Rule::X_tests;
for my $test (keys %X_tests) {
    $test =~ s/^-//;
    my $sub = eval 'sub () {
        my $self = _force_object shift;
        push @{ $self->{rules} }, {
           code => "\$self->{_virtual}->test(q{' . $test . '}, \$_)",
           rule => "'.$X_tests{"-$test"}.'",
        };
        $self;
    } ';
    no strict 'refs';
    *{ $X_tests{"-$test"} } = $sub;
}

{
    our @stat_tests;
    *stat_tests = \@File::Find::Rule::stat_tests;

    my $i = 0;
    for my $test (@stat_tests) {
        my $index = $i++; # to close over
        my $sub = sub {
            my $self = _force_object shift;

            my @tests = map { Number::Compare->parse_to_perl($_) } @_;

            push @{ $self->{rules} }, {
                rule => $test,
                args => \@_,
                code => 'do { my $val = ($self->{_virtual}->stat($_))['.$index.'] || 0;'.
                  join ('||', map { "(\$val $_)" } @tests ).' }',
            };
            $self;
        };
        no strict 'refs';
        *$test = $sub;
    }
}



1;

__END__


=head1 AUTHOR

Richard Clamp <richardc@unixbeard.net>

=head1 COPYRIGHT

Copyright 2004 Richard Clamp.  All Rights Reserved.

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.


=head1 BUGS

None known.

Bugs should be reported to me via the CPAN RT system.
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File::Find::Rule::Filesys::Virtual>.


=head1 SEE ALSO

L<File::Find::Rule>, L<Filesys::Virtual>, L<Net::DAV::Server>

=cut
