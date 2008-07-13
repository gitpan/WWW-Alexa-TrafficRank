package WWW::Alexa::TrafficRank;

use strict;
use warnings;
use vars qw($VERSION);
use LWP::UserAgent;

$VERSION = '1.0';

sub new
{
  my $class = shift;
  my %par = @_;
  my $self;
  
  $self->{ua} = LWP::UserAgent->new(agent => $par{agent} || 'Opera 9.5') or return;
  $self->{ua}->proxy('http', $par{proxy}) if $par{proxy};
  $self->{ua}->timeout($par{timeout}) if $par{timeout};

  bless($self, $class);
}

sub get 
{
  my ($self, $domain) = @_;
  return unless defined $domain;

  my ($res, $cont);

  $domain =~ s/^\w+\.(.*?\.\w+)/$1/;

  $res = $self->{ua}->get("http://www.alexa.com/data/details/main/$domain");
  if (!$res->is_success) {
    return $res->status_line;
  }

  $cont = $res->content; $cont =~ s/[\r\n]//g;

  if ($cont =~ /traffic rank of:<\/span>&nbsp;No Data/i) {
    return "No Data";
  }

  $res = $self->{ua}->get("http://client.alexa.com/common/css/scramble.css");
  if (!$res->is_success) {
    return $res->status_line;
  }

  my $cont_css = $res->content; $cont_css =~ s/[\r\n]//g;

  my ($rank) = $cont =~ /traffic rank of:<\/span>&nbsp;<a href="\/data\/details\/traffic_details\/$domain">(.*?)<\/a>/i;
     $rank =~ s|<!--.*?-->||g;
     $rank =~ s|<span class="descBold">||g;
     $rank =~ s|</span>|</span>\n|gi;
  my @spans = split(/\n/, $rank); $rank='';

  foreach my $span(@spans) {
    my ($cls) = $span =~ /<span class="(.*?)">.*?<\/span>/i;
    if ($cls && $cont_css =~ /$cls/i) {
      $span =~ s|<span class=".*?">.*?</span>$||i;
    }
    else {
      $span =~ s|<span class=".*?">||i;
      $span =~ s|</span>||i;
    }
    $rank .= $span;
  }

  return $rank;
}

1;

__END__

=head1 NAME

WWW::Alexa::TrafficRank - Query Alexa.com Traffic Rank of website.

=head1 SYNOPSIS

 use WWW::Alexa::TrafficRank;
 my $tr = WWW::Alexa::TrafficRank->new;
 print $tr->get('guruperl.net');

=head1 DESCRIPTION

The C<WWW::Alexa::TrafficRank> is a class implementing a interface for
querying Alexa.com Traffic Rank.

To use it, you should create C<WWW::Alexa::TrafficRank> object and use its
method get(), to query traffic rank of Domain.

It uses C<LWP::UserAgent> for making request to Alexa.com

=head1 CONSTRUCTOR METHOD

=over 4

=item  $tr = WWW::Alexa::TrafficRank->new(%options);

This method constructs a new C<WWW::Alexa::TrafficRank> object and returns it.
Key/value pair arguments may be provided to set up the initial state.
The following options correspond to attribute methods described below:

  KEY                     DEFAULT
  -----------             --------------------
  agent                   "Opera 9.5"
  proxy                   undef
  timeout                 undef

C<agent> specifies the header 'User-Agent' when querying Alexa. If
the C<proxy> option is passed in, requests will be made through
specified poxy. C<proxy> is the host which serve requests to Alexa.

=back

=head1 QUERY METHOD

=over 4

=item  $rank = $tr->get('guruperl.net');

Queries Alexa for a specified traffic rank URL and returns traffic rank
text value. If query fails for some reason (alexa unreachable, undefined 
url passed) it return error string.

=back

=head1 BUGS

If you find any, please report ;)

=head1 AUTHOR

Alex S. Danoff
  F<E<lt>root@guruperl.netE<gt>>.
  http://www.guruperl.net/
  icq: 10608

=head1 COPYRIGHT

Copyright 2008, Alex S. Danoff, All Rights Reserved.

You may use, modify, and distribute this package under the
same terms as Perl itself.
