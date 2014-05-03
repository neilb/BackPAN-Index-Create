#! perl

use strict;
use warnings;
use Test::More 0.88 tests => 4;
use File::Compare qw/ compare /;

use BackPAN::Index::Create qw/ create_backpan_index /;

my $generated_file_name = 't/generated-releases-index.txt';
my $expected_file_name  = 't/expected-releases-index.txt';

eval {
    create_backpan_index({
        basedir         => 't/testpan',
        output          => $generated_file_name,
        releases_only   => 1,
    });
};

ok(!$@, "create_backpan_index() should without croaking");
ok(compare($generated_file_name, $expected_file_name) == 0,
   "generated releases index should match the expected content");
ok(unlink($generated_file_name),
   "Should be able to remove the generated index file");
ok(!-f $generated_file_name,
   "The generated file should no longer exist");

