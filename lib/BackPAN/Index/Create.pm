package BackPAN::Index::Create;

use 5.006;
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
        croak "create_backpan_index() expects a single hashref argument\n";
    }
    my $argref        = shift;
    my $basedir       = $argref->{basedir}
                        || croak "create_backpan_index() must be given a 'basedir'\n";
    my $author_dir    = catfile($basedir, 'authors');
    my $stem          = catfile($author_dir, 'id');
    my $releases_only = $argref->{releases_only} || 0;
    my $fh;

    if (not -d $author_dir) {
        croak "create_backpan_index() can't find 'authors' directory in basedir ($basedir)\n";
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

    if ($releases_only) {
        # A 'releases only' index contains just the tarballs
        # and the paths don't include the leading 'authors/id'
        # Does a BackPAN ever contain anything in a directory
        # other than authors?
        $rule->and(sub { /\.(tar\.gz|tgz|zip)$/ }) if $releases_only;
        $stem = catfile($author_dir, 'id');
    }
    else {
        $stem = $basedir;
    }

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

=head1 NAME

BackPAN::Index::Create - generate an index file for a BackPAN mirror

=head1 SYNOPSIS

 use BackPAN::Index::Create qw/ create_backpan_index /;

 create_backpan_index({
      basedir       => '/path/to/backpan'
      releases_only => 0 | 1,
      output        => 'backpan-index.txt',
 });

=head1 DESCRIPTION

B<BackPAN::Index::Create> creates a text index file for a BackPAN index.
By default it will generate an index that looks like this:

 #FORMAT 1
 authors/id/B/BA/BARBIE/Acme-CPANAuthors-British-1.01.meta.txt 1395991503 1832
 authors/id/B/BA/BARBIE/Acme-CPANAuthors-British-1.01.readme.txt 1395991503 1912
 authors/id/B/BA/BARBIE/Acme-CPANAuthors-British-1.01.tar.gz 1395991561 11231

The first line is a comment that identifies the revision number of the index format.
For each file in the BackPAN mirror the index will then contain one line.
Each line contains three items:

=over 4

=item * path

=item * timestamp

=item * size (in bytes)

=back

If the C<releases_only> option is true, then the index will only contain
release tarballs, and the paths won't include the leading C<authors/id/>:

 #FORMAT 1
 B/BA/BARBIE/Acme-CPANAuthors-British-1.01.tar.gz 1395991561 11231

=head1 SEE ALSO

L<create-backpan-index> - a script that provides a command-line interface to this module,
included in the same distribution.

L<BackPAN::Index> - an interface to an alternate BackPAN index.

=head1 REPOSITORY

L<https://github.com/neilbowers/BackPAN-Index-Create>

=head1 AUTHOR

Neil Bowers E<lt>neilb@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Neil Bowers <neilb@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

