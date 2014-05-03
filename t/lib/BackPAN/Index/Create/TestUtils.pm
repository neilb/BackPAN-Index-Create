package BackPAN::Index::Create::TestUtils;

use strict;
use warnings;

use File::Touch;
use parent 'Exporter';

our @EXPORT_OK = qw/ setup_testpan /;


sub setup_testpan
{
    return touch_file('t/testpan/authors/id/P/PO/POGLE/Wood-Pogle-0.001.meta'          => 1399111341)
           && touch_file('t/testpan/authors/id/P/PO/POGLE/Wood-Pogle-0.001.readme'     => 1399111357)
           && touch_file('t/testpan/authors/id/P/PO/POGLE/Wood-Pogle-0.001.tar.gz'     => 1399111421)
           && touch_file('t/testpan/authors/id/Z/ZA/ZAPHOD/Heart-Of-Gold-0.01.meta'    => 1399110691)
           && touch_file('t/testpan/authors/id/Z/ZA/ZAPHOD/Heart-Of-Gold-0.01.readme'  => 1399110713)
           && touch_file('t/testpan/authors/id/Z/ZA/ZAPHOD/Heart-Of-Gold-0.01.tar.gz'  => 1399111170);
}

sub touch_file
{
    my ($filename, $time) = @_;
    my $toucher           = File::Touch->new(mtime => $time);

    return $toucher->touch($filename);
}
