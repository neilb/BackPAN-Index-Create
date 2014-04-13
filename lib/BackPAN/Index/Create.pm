package BackPAN::Index::Create;

use 5.016;
use strict;
use warnings;
use Exporter::Lite;
use Path::Iterator::Rule;
use Scalar::Util qw/ reftype /;
use File::Spec::Functions qw/ catfile /;
use Carp;
use autodie;

our @EXPORT_OK      = qw(create_backpan_index);
my $FORMAT_REVISION = 1;

sub create_backpan_index
{
    if (@_ != 1 || reftype($_[0]) ne 'HASH') {
        croak __SUB__, "() expects a single hashref argument\n";
    }
    my $argref        = shift;
    my $basedir       = $argref->{basedir}
                        || croak __SUB__, "() must be given a 'basedir'\n";
    my $author_dir    = catfile($basedir, 'authors');
    my $stem          = catfile($author_dir, 'id');
    my $releases_only = $argref->{releases_only} // 0;
    my $fh;

    if (not -d $author_dir) {
        croak __SUB__, "() can't find 'authors' directory in basedir ($basedir)\n";
    }

    if (exists($argref->{output})) {
        open($fh, '>', $argref->{output});
    }
    else {
        $fh = \*STDOUT;
    }

    print $fh "#FORMAT $FORMAT_REVISION\n";

    my $rule = Path::Iterator::Rule->new();

    $rule->file->name("*");
    $rule->and(sub { /\.(tar\.gz|tgz|zip)$/ }) if $releases_only;
    foreach my $path ($rule->all($author_dir)) {
        my $tail = $path;
           $tail =~ s!^${stem}[^A-Za-z0-9]+!!;
        my @stat = stat($path);
        my $time = $stat[9];
        my $size = $stat[7];
        printf $fh "%s %d %d\n", $tail, $time, $size;
    }
}

1;

