#!/usr/bin/perl

use Test::More tests => 49;
use Path::Class qw[ file dir ];

my $dir   = dir( qw[ path to some ] );
my @data = (
    +{ file => $dir->file( 'file.pl' ),  suffix => '.pl',  extension => 'pl' },                             # perl
    +{ file => $dir->file( 'file.pod' ), suffix => '.pod', extension => 'pod' },                            # pod
    +{ file => $dir->file( 'file' ),     suffix => '',     extension => undef },                            # bare
    +{ file => $dir->file( 'file.' ),    suffix => '.',    extension => '' },                               # dotty
    +{ file => $dir->file( 'file.foo.bar' ), stem => 'file.foo', suffix => '.bar', extension => 'bar' },    # double
);

for my $data ( @data ) {
    my $basename = $data->{file}->basename;
    my $file = $data->{file};
    my $stem = $data->{stem} || 'file';
    is $file->stem, $stem or diag "Failed test was: stem of '$basename'";
    for my $suf ( qw[ suffix extension ] ) {
        is $file->$suf, $data->{extension} or diag "Failed test was: $suf of $basename";
    }
    is $file->stem . $data->{suffix}, $basename or diag "Failed test was: roundtrip $basename";
    for my $suf ( qw[ pl .pl . ] ) {
        my $expected = $dir->file("$stem.$suf")->stringify;
        $expected =~ s/\.\././g;
        is $file->with_suffix( $suf ), $expected or diag "Failed test was: resuffix $file with $suf";
    }
    {
        my $other_file = $dir->file( 'other' )->with_suffix( $data->{suffix} )->stringify;
        for my $other_stem ( qw[ other other. ] ) {
            is $file->with_stem($other_stem), $other_file
                or diag "Failed test was: $basename with stem '$other_stem' and suffix '$data->{suffix}'";
        }
    }
}
{
    my $file = $dir->file( 'quux.foo' );
    my $basename = $file->basename;
    my $basefile = $file->basefile;
    isa_ok $basefile, ref($file), 'class of basefile';
    is $basefile, $basename or diag 'Failed test was: basefile eq basename';
    is $basefile->with_suffix('bar'), 'quux.bar' or diag 'Failed test was: basefile with_suffix';
    is $basefile->with_stem('baz'), 'baz.foo' or diag 'Failed test was: basefile with_stem';
}


done_testing;
