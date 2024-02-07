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

use HTTP::UserAgent;
use JSON::Fast <immutable>;

class WWW::KanbanFlow {
    submethod TWEAK() {
        $!ua.auth('apiToken', $!api-token);
    }

    method get-board() {
        my $response = $!ua.get("https://kanbanflow.com/api/v1/board");

        from-json($response.content)
    }

    has Str $.api-token is required;

    has $!ua = HTTP::UserAgent.new(:throw-exceptions);
};
