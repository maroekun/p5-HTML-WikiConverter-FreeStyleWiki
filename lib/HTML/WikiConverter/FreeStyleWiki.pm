package HTML::WikiConverter::FreeStyleWiki;
use strict;
use warnings;
use base 'HTML::WikiConverter';

our $VERSION = '0.001';


sub rules {
  my %rules = (
    hr => { replace => "\n----\n" },
    br => { replace => "\n" },

    blockquote => { start => qq{\n""}, block => 1, line_format => 'multi' },
    p => { block => 1, trim => 'both', line_format => 'multi' },
    i => { start => q{''}, end => q{''} },
    em => { alias => 'i' },
    b => { start => q{'''}, end => q{'''} },
    strong => { alias => 'b' },
    del => { start => '==', end => '==' },
    ins => { start => '__', end => '__' },

    img => { replace => \&_image },
    a => { replace => \&_link },

    ul => { line_format => 'multi', block => 1 },
    ol => { alias => 'ul' },
    dl => { line_format => 'blocks', block => 1 },

    li => { start => \&_li_start, trim => 'leading' },
    dt => { start => '::', trim => 'both', 'end' => "\n"},
    dd => { line_format => 'multi', line_prefix => ':::' },

    td => { start => ',', trim => 'both' },
    th => { alias => 'td' },
    tr => { end   => "\n" },

    h1 => { start => '!!!', block => 1, trim => 'both', line_format => 'single' },
    h2 => { start => '!!!', block => 1, trim => 'both', line_format => 'single' },
    h3 => { start => '!!',  block => 1, trim => 'both', line_format => 'single' },
    h4 => { start => '!',   block => 1, trim => 'both', line_format => 'single' },
    h5 => { start => '!',   block => 1, trim => 'both', line_format => 'single' },
    h6 => { start => '!',   block => 1, trim => 'both', line_format => 'single' },

    pre => { line_format => 'multi', line_prefix => ' '},
  );

  $rules{$_} = { preserve => 1 } for qw/ big small tt abbr acronym cite code dfn kbd samp var sup sub /;
  return \%rules;
}

# Calculates the prefix that will be placed before each list item.
# List item include ordered and unordered list items.
sub _li_start {
  my( $self, $node, $rules ) = @_;
  my @parent_lists = $node->look_up( _tag => qr/ul|ol/ );
  my $depth = @parent_lists;

  my $bullet = '';
  $bullet = '*' if $node->parent->tag eq 'ul';
  $bullet = '+' if $node->parent->tag eq 'ol';

  my $prefix = ( $bullet ) x $depth;
  return "\n$prefix ";
}

sub _image {
  my( $self, $node, $rules ) = @_;
  my $url = $node->attr('src') || '';
  if ($url =~ m{page=([^&]*)&(?:amp;)?file=([^&]*)&(?:amp;)?action=ATTACH}msx) { # ref_image plugin
      return sprintf "{{ref_image %s,%s}}", $2, $1 if $2
  }
  elsif($url) { # image plugin
      return sprintf "{{image %s}}", $url
  }
  return '';
}

sub _link {
  my( $self, $node, $rules ) = @_;
  my $url = $node->attr('href') || '';
  my $title = $self->get_wiki_page($url) || '';
  my $text = $self->get_elem_contents($node) || '';
  return "[[$text]]" if $title eq $text;
  return "[[$text]]" if lcfirst $title eq $text;
  return "[[$text|$title]]" if $title;
  return $url if $url eq $text;
  return "[$text|$url]";
}

# XXX doesn't handle rowspan
sub _td_start {
  my( $self, $node, $rules ) = @_;
  return ','
}

sub _td_end {
  my( $self, $node, $rules ) = @_;
  return '';
}

sub preprocess_node {
  my( $self, $node ) = @_;
  $self->strip_aname($node) if $node->tag eq 'a';
  $self->caption2para($node) if $node->tag eq 'caption';

  # Bug 17550 (https://rt.cpan.org/Public/Bug/Display.html?id=17550)
  $node->postinsert(' ') if $node->tag eq 'br' and $node->right and $node->right->tag eq 'br';
}

=pod

=head1 NAME

HTML::WikiConverter::FreeStyleWiki - Convert HTML to FreeStyleWiki markup

=head1 SYNOPSIS

  use HTML::WikiConverter;
  my $wc = new HTML::WikiConverter( dialect => 'FreeStyleWiki' );
  print $wc->html2wiki( $html );

=head1 DESCRIPTION

This module contains rules for converting HTML into FreeStyleWiki
markup. See L<HTML::WikiConverter> for additional usage details.

=cut

=head1 AUTHOR

Yusuke Watase E<lt>ywatase@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
