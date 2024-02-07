=begin pod

=head1 NAME

WWW::KanbanFlow - Raku interface to the KanbanFlow API.

=head1 SYNOPSIS

=begin code

use WWW::KanbanFlow;

my $api = WWW::KanbanFlow.new(
        api-token => 'your-api-token'
    );

my $board = $api.get-board;

=end code

=head1 DESCRIPTION

To use this module you need to have a KanbanFlow account and an API token,
which can be generated in the "API & Webhooks" section of the settings screen
of your board.

Generally speaking, the API of this class maps one-to-one to the API provided
by KanbanFlow, please refer to its documentation for more details.

=end pod

use Cro::HTTP::Client;

class WWW::KanbanFlow {
    submethod TWEAK() {
        $!ua = Cro::HTTP::Client.new(
            auth => {
                username => 'apiToken',
                password => $!api-token
            },
            base-uri     => 'https://kanbanflow.com/api/v1/',
            content-type => 'application/json'
        );
    }

    method get-board() {
        my $response = await $!ua.get("board");

        await $response.body
    }

    has Str $.api-token is required;

    has $!ua;
}
