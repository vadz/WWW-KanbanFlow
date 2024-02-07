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

my $task = $api.create-task(
        name => 'My brand new task'
    );

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

    class Task {
        has Str $.id is required;
    }

    method create-task(Str:D $name --> Task) {
        # TODO: Currently we always create the task in the first column
        # and use deprecated "columnIndex" parameter. We should allow
        # specifying the column and use "columnId" instead.
        my %body =
            name => $name,
            columnIndex => 0
        ;
        my $response = await $!ua.post('tasks', :%body);

        my $res = await $response.body;
        Task.new(id => $res<taskId>)
    }

    method delete-task(Task:D $task) {
        await $!ua.delete("tasks/{$task.id}");
    }

    has Str $.api-token is required;

    has $!ua;
}
