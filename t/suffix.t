#!/usr/bin/perl

# Test suffix/stem/dir juggling methods for Path::Class::File

use strict;
use warnings;

use Test::More;
use Path::Class;

my $file = file( 'path/to/some/file.ext' );
my $other_dir = dir( 'some/other/path' );

my $basefile = $file->basefile;
isa_ok $basefile, 'Path::Class::File', "basefile is a Path::Class::File";
is $basefile->as_foreign('Unix'), 'file.ext', "basefile stringifies correctly";

{
    my $suffix = $file->suffix;
    is $suffix, 'ext', "suffix() returns the expected value";

    my $extension = $file->extension;
    is $extension, $suffix, "extension() returns the same value as suffix()";
}

{
    my $stem = $file->stem;
    is $stem, 'file', "stem() returns the expected value";

    my $without = $file->without_extension;
    is $without, $stem, "without_extension() returns the same value as stem()";
}

{
    my $extensive = file( 'path/to/zero.one.two.three' );

    my $bare = $extensive->bare;
    is $bare, 'zero', "bare() returns the expected value";

    my $stem = $extensive->stem;
    is $stem, 'zero.one.two', "stem() removes the last extension";
    isnt $stem, $bare, "stem() and bare() return different values when more than one extension";

    is $extensive->suffix, 'three', "suffix returns the last extension of many";

    is $file->bare, $file->stem, "stem() and bare() return the same thing with only one extension";
}

{
    my $other = $file->with_suffix('suf');
    is $other->as_foreign('Unix'), 'path/to/some/file.suf', "with_suffix() return value stringifies as expected";
    is $file->with_suffix('.suf')->as_foreign('Unix'), $other->as_foreign('Unix'), "with_suffix() ignores pre-existing dot";
    is $file->with_suffix('.ext'), $file, "replace suffix with an identical one";

    is $basefile->with_suffix('.suf'), $other->basename, '$file->basefile->with_suffix(...) eq $other->basename';

    is $file->with_extension('suf'), $other, "with_suffix() returns the expected value";
}

done_testing;
