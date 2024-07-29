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

    method !check-rate-limit($response) {
        my $remaining = $response.header('X-RateLimit-Remaining');
        if $remaining.Int < 10 {
            my $reset-time = DateTime.new($response.header('X-RateLimit-Reset').Int);
            die "Only $remaining requests left, wait until $reset-time in order to avoid rate limiting";
        }
    }

    method get-board() {
        my $response = await $!ua.get("board");

        self!check-rate-limit($response);

        await $response.body
    }

    # These names are fixed by the API.
    enum Color <yellow white red green blue purple orange cyan brown magenta>;

    class TaskParams {
        has Str $.name is required;
        has Color $.color;
        has Str $.description;

        # TODO: This is incomplete, more parameters can be provided when
        # creating a task.
    }

    class Task {
        has Str $.id is required;
        has TaskParams $.params handles <name color description>;
    }

    method create-task(TaskParams:D $params --> Task) {
        # TODO: Currently we always create the task in the first column
        # and use deprecated "columnIndex" parameter. We should allow
        # specifying the column and use "columnId" instead.
        my %body =
            name => $params.name,
            columnIndex => 0,
        ;

        %body<color> = $params.color if $params.color.defined;
        %body<description> = $params.description if $params.description.defined;

        my $response = await $!ua.post('tasks', :%body);

        self!check-rate-limit($response);

        my $res = await $response.body;
        Task.new(id => $res<taskId>, params => $params)
    }

    method delete-task(Task:D $task) {
        my $response = await $!ua.delete("tasks/{$task.id}");

        self!check-rate-limit($response);
    }

    # Set value of a custom numeric field.
    method set-numeric-field(Task:D $task, Str:D $field-id, Numeric $value) {
        my %body = value => { number => $value };
        my $response = await $!ua.post("tasks/{$task.id}/custom-fields/$field-id", :%body);

        self!check-rate-limit($response);
    }

    has Str $.api-token is required;

    has $!ua;
}
