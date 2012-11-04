#/usr/bin/env perl
#===============================================================================
#Last Modified:  2012/11/02
#===============================================================================
use warnings;
use strict;
use Test::More 0.96;
use Test::Differences;
use utf8;
use HTML::WikiConverter;

my $wiki;
{ local $/ = undef; local *FILE; open FILE, '<', "./t/test.wiki"; $wiki = <FILE>; close FILE }
my $html;
{ local $/ = undef; local *FILE; open FILE, '<', "./t/test.html"; $html = <FILE>; close FILE }

my $wc = HTML::WikiConverter->new(dialect => 'FreeStyleWiki');
my $converted_wiki = $wc->html2wiki(html => $html);

unified_diff;
eq_or_diff ($converted_wiki, $wiki, 'convert');

done_testing;
