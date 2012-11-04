#/usr/bin/env perl
#===============================================================================
#Last Modified:  2012/11/02
#===============================================================================
use Test::More 0.96;
use HTML::WikiConverter;

my $have_lwp         = eval "use LWP::UserAgent; 1";
my $have_query_param = eval "use URI::QueryParam; 1";

my $wc = new HTML::WikiConverter(
    dialect  => 'HTML::WikiConverter::FreeStyleWiki',
    base_uri => 'http://www.example.com',
    wiki_uri =>
        [ 'http://www.example.com/wiki/', 'http://www.example.com/images/', \&extract_wiki_page ],
);

sub extract_wiki_page {
    my ( $wc, $url ) = @_;
    return $have_query_param ? $url->query_param('page') : $url =~ /page\=([^&]+)/ && $1;
}

my $testcases = make_testcases();

foreach my $t (@$testcases) {
    is( $wc->html2wiki( html => $t->[0] ), $t->[1], $t->[2] );
}

sub make_testcases {
    my @tests = (
        [ '<b>text</b>',                              q{'''text'''},                  'bold' ],
        [ '<i>text</i>',                              q{''text''},                    'ital' ],
        [ '<a href="http://example.com">Example</a>', '[Example|http://example.com]', 'link' ],
        [ '<blockquote>text1</blockquote>', '""text1', 'blockquote' ],
        [   '<blockquote>text1<blockquote>text2</blockquote></blockquote>', qq{""text1\n""text2},
            'nested blockquote change to plain blockquote'
        ],
        [ '<a href="/">Example</a>', '[Example|http://www.example.com/]', 'relative URL in link' ],
        [ '<strong>text</strong>',   q{'''text'''},                       'strong' ],
        [ '<em>text</em>',           q{''text''},                         'em' ],
        [ '<a href="/wiki/Example">Example</a>',    '[[Example]]',          'wiki link' ],
        [ '<img src="?page=FrontPage&amp;file=image%2Ejpg&amp;action=ATTACH"/>', '{{ref_image image.jpg,FrontPage}}', 'ref_image plugin' ],
        [ '<img src="http://sub.example.com/img.jpg "/>', '{{image http://sub.example.com/img.jpg}}', 'image plugin : direct link to other domian site.' ],
        [   '<a href="/wiki/index.php?title=Thingy&amp;action=view">Text</a>',
            '[[Text]]', 'long wiki url'
        ],
    );
    return \@tests;
}

done_testing;
