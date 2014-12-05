#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 8;
use Path::Class qw[ file tempdir ];

use utf8;

my $text = <<'END_OF_TEXT';
The word 'green' is:
• Old English:  grēn
• Old Norse:    grœnn
• Swedish:      grön
• Danish:       grøn
• Greek:        χλωρός
END_OF_TEXT

# Ensure the right line terminator
local $/ = qq{
};

my @split_text = split m{$/}, $text;
my @text_lines = map { $_ . $/ } @split_text;

my @data = (
    [ text => $text ],
    [ lines => \@text_lines ],
    [ split => \@split_text => 'spew_lines_utf8' ],
);

my $dir = tempdir( CLEANUP => 1 );
{
    my $text_file = $dir->file( 'text.txt' );
    my $write_text_fh = $text_file->openw_utf8;
    $write_text_fh->print($text);
    $write_text_fh->close;
    my $lines_file = $dir->file( 'lines.txt' );
    my $write_lines_fh = $lines_file->openw_utf8;
    $write_lines_fh->print(@text_lines);
    $write_lines_fh->close;
    for my $file ( $text_file, $lines_file ) {
        my $name = $file->basename;
        my $read_lines_fh = $file->openr_utf8;
        my @read_lines = <$read_lines_fh>;
        close $read_lines_fh;
        is_deeply \@read_lines, \@text_lines, "read lines from $name";
        my $read_text_fh = $file->openr_utf8;
        my $read_text = do{ local $/; <$read_text_fh>; };
        is $read_text, $text, "read text from $name";
    }
    my $append_fh = $text_file->opena_utf8;
    $append_fh->print($text);
    close $append_fh;
    my $read_appended_fh = $text_file->openr_utf8;
    my $read_appended = do { local $/; <$read_appended_fh>; };
    close $read_appended_fh;
    is $read_appended, $text . $text, "appended text";
}

for my $data ( @data ) {
    my( $name, $contents, $spew ) = @$data;
    $spew ||= 'spew_utf8';
    subtest "$spew $name" => sub {
        plan tests => 2;
        my $file = $dir->file("$spew-$name.txt");
        my $basename = $file->basename;
        $file->$spew($contents);
        my $slurped_text = $file->slurp_utf8;
        is $slurped_text, $text, "slurp $name as text";
        my @slurped_lines = $file->slurp_utf8;
        is_deeply \@slurped_lines, \@text_lines, "slurp $name as lines";
    };
}

done_testing;
