package Net::OAuth2::Profile::WebServer;
use warnings;
use strict;
use base qw(Net::OAuth2::Profile::Base);
use JSON;
use URI;
use Net::OAuth2::AccessToken;
use HTTP::Request;

__PACKAGE__->mk_accessors(qw/redirect_uri/);

sub authorize_params {
  my $self = shift;
  my %options = $self->SUPER::authorize_params(@_);
  $options{type} = 'web_server';
  $options{redirect_uri} = $self->redirect_uri if defined $self->redirect_uri;
  return %options;
}

sub get_access_token {
  my $self = shift;
  my $code = shift;
  my %req_params = @_;
  my $response = $self->client->request(HTTP::Request->new(
    POST => $self->client->access_token_url($self->access_token_params($code, %req_params))
  ));
  my $res_params = _parse_json($response->decoded_content);
  $res_params->{client} = $self->client;
  return Net::OAuth2::AccessToken->new(%$res_params);
}

sub access_token_params {
  my $self = shift;
  my $code = shift;
  my %options = $self->SUPER::access_token_params(@_);
  $options{type} = 'web_server';
  $options{code} = $code;
  $options{redirect_uri} = $self->redirect_uri if defined $self->redirect_uri;
  return %options;
}

sub _parse_query_string {
  my $str = shift;
  my $uri = URI->new;
  $uri->query($str);
  return $uri->query_form;
}

sub _parse_json {
  my $str = shift;
  my $obj = decode_json($str);
  return $obj;
}

=head1 NAME

Net::OAuth2::Profile::WebServer - OAuth Web Server Profile

=head1 SEE ALSO

L<Net::OAuth>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Keith Grennan.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut


1;