use Test2::V0;
use Foo;
use Data::Dumper;

my $val = { event_type => YAML::LibYAML::API::FFI::event_type::YAML_SCALAR_EVENT };
my $c = Event->new($val);
diag $c->as_string;


subtest create_in_perl => sub {
    my $style = Foo::YamlScalarStyle::YAML_FOLDED_SCALAR_STYLE;
    my $event = Event->new({
        event_type => YAML::LibYAML::API::FFI::event_type::YAML_SCALAR_EVENT,
        data => {
            scalar => {
                length => 3,
                plain_implicit => 1,
                quoted_implicit => 1,
                tag => 'abc',
                anchor => 'def',
                style => 3,
                value => 'abcd',
            },
        },
    });
    # strings not yet working
    #is $event->data->scalar->value, "lala", "value";
    is $event->data->scalar->style, 3, "scalar style";
};

subtest scalar => sub {
    my $new_event = Event->new;
    my $style = Foo::YamlScalarStyle::YAML_FOLDED_SCALAR_STYLE;
    my $ret = Foo::yaml_scalar_event_initialize($new_event, "Anc", "Tag", "lala", -1, 1, 0, $style);
    diag $new_event->as_string;
#    diag $new_event->data->scalar->style;
#    diag $new_event->data->scalar->value;
    is $new_event->event_type, YAML::LibYAML::API::FFI::event_type::YAML_SCALAR_EVENT, "type";
    #is $new_event->data->scalar->value, "lala", "value";
    is $new_event->data->scalar->plain_implicit, 1, "plain_implicit";
    is $new_event->data->scalar->style, $style, "scalar style";
    is $new_event->start_mark, "Mark(0):[L:0 C:0]", "start_mark";
};

subtest stream_start => sub {
    my $stream_start = Event->new;
    my $ret = Foo::yaml_stream_start_event_initialize($stream_start, 0);
    diag $stream_start->as_string;
    is $stream_start->as_string, "Event(1) +STR", "stream_start_event";
};

subtest sequence_start => sub {
    my $event = Event->new;
    my $sstyle = Foo::YamlSequenceStyle::YAML_FLOW_SEQUENCE_STYLE;
    my $ret = Foo::yaml_sequence_start_event_initialize($event, "Anc", "Tag", 1, $sstyle);
    diag $event->as_string;
    is $event->data->sequence_start->style, $sstyle, "sequence style";
};

done_testing;
