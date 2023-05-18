use Test2::V0;
use v5.22;
use Foo;
use Data::Dumper;

subtest parse => sub {
    my $parser = Foo::Parser->new;
    my $ok = Foo::yaml_parser_initialize($parser);
    is $parser->error, 0, "error";
    my $input = "input";
    is $parser->read_handler, undef, "read_handler";
    Foo::yaml_parser_set_input_string($parser, $input, length($input));
    is $parser->state, 0, "state";
    my $events;
    while (1) {
        my $event = Foo::Event->new;
        my $ok = Foo::yaml_parser_parse($parser, $event);
        my $error = $parser->error;
        my $type = $event->type;
        my $str = $event->as_string;
        diag "Event: $str";
        push @$events, $event;
        Foo::yaml_event_delete($event);
        last unless $ok;
        last if $type == Foo::event_type::YAML_STREAM_END_EVENT;
    }
    Foo::yaml_parser_delete($parser);
    is scalar @$events, 5, "event number";
};

done_testing;