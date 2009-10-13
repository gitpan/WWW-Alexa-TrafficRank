package WWW::Alexa::TrafficRank;

use strict;
use warnings;
use vars qw($VERSION);
use LWP::UserAgent;

$VERSION = '1.6';

sub new
{
    my $class = shift;
    my %par = @_;
    my $self;
  
    $self->{ua} = LWP::UserAgent->new(agent => $par{agent} || 'Opera 10.0') or return;
    $self->{ua}->proxy('http', $par{proxy}) if $par{proxy};
    $self->{ua}->timeout($par{timeout})     if $par{timeout};

    bless ($self, $class);
}

sub get 
{
    my ($self, $domain) = @_;

    return unless defined $domain;

    my $res = $self->{ua}->get("http://www.alexa.com/siteinfo/$domain");
    return $res->status_line if !$res->is_success;

    my $cont = $res->content; $cont =~ s/[\r\n]//g;

    my ($updown, $rank) = $cont =~ /<div class="data (up|down|steady)"><img.*?\/>\s+([\d,]+)<\//i;

    return $rank;
}

sub get_country_rank
{
    my $self = shift;
    my $par  = { @_ };

    return unless defined $par->{Domain};
    return unless defined $par->{Country};

    my $res = $self->{ua}->get("http://www.alexa.com/siteinfo/$par->{Domain}");
    return $res->status_line if !$res->is_success;

    my $cont = $res->content; $cont =~ s/[\r\n]//g;

    return 0 unless $cont =~ /is ranked around the world(.+?)<\/ul>/gs;
  
    my $listdata = $1;

    while ( $listdata =~ /<li class="geo_percentages">(.+?)<\/li>/igs ) {
        my $item = $1;

        if ( $item =~ /$par->{Country}/gs ) {
            my ($rank) = $item =~ /<span class="geo_number descbold">([\d,]+)</i;

            return $rank;
        }
    }
  
    return 0;
}

1;

__END__

=head1 NAME

WWW::Alexa::TrafficRank - Query Alexa.com Traffic Rank of website.

=head1 SYNOPSIS

use WWW::Alexa::TrafficRank;
 
my $tr = WWW::Alexa::TrafficRank->new();
 
my $rank = $tr->get('guruperl.net');
my $country_rank = $tr->get_country_rank(Domain => 'guruperl.net', Country => 'United States');
 
print $rank, "\n", $country_rank;

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
  agent                   "Opera 10.0"
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
text value. If query fails for some reason (Alexa unreachable, undefined 
url passed) it return error string.

=item  $country_rank = $tr->get_country_rank(Domain => 'guruperl.net', Country => 'United States');

Extract the rank in the country. If we get a match on the country name in 
the item then extract the ranking value and return. The country name must match the name 
of the country as displayed on the Alexa page.

=back

=head1 BUGS

If you find any, please report ;)

=head1 AUTHOR

Guruperl.net
  F<E<lt>root@guruperl.netE<gt>>.
  http://www.guruperl.net/

=head1 COPYRIGHT

Copyright 2009, Guruperl.net, All Rights Reserved.

You may use, modify, and distribute this package under the
same terms as Perl itself.
