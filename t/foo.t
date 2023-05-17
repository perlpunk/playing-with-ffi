use Test2::V0;
use Foo;
use Data::Dumper;

subtest stream_start => sub {
    my $stream_start = Event->new;
    my $encoding = Foo::YamlEncoding::YAML_UTF8_ENCODING;
    my $ret = Foo::yaml_stream_start_event_initialize($stream_start, $encoding);
    is $stream_start->data->stream_start->encoding, $encoding, 'encoding';
    is $stream_start->as_string, "##### Event(1) +STR", "stream_start_event";
};

subtest sequence_start => sub {
    my $event = Event->new;
    my $sstyle = Foo::YamlSequenceStyle::YAML_FLOW_SEQUENCE_STYLE;
    my $ret = Foo::yaml_sequence_start_event_initialize($event, "Anc", "TAG", "dummy", 1, $sstyle);
    diag $event->as_string;
    is $event->data->sequence_start->anchor_str, 'Anc', 'anchor';
    is $event->data->sequence_start->tag_str, 'TAG', 'tag';
    is $event->data->sequence_start->val_str, 'dummy', 'val';
    is $event->data->sequence_start->implicit, 1, 'implicit';
    is $event->data->sequence_start->style, $sstyle, "sequence style";
};

subtest scalar => sub {
    my $event = Event->new;
    my $style = Foo::YamlScalarStyle::YAML_FOLDED_SCALAR_STYLE;
    my $ret = Foo::yaml_scalar_event_initialize($event, "Anc", "Tag", "lala", -1, 1, 1, $style);
    is $event->data->sequence_start->anchor_str, 'Anc', 'anchor';
    is $event->data->sequence_start->tag_str, 'Tag', 'tag';
    is $event->event_type, Foo::event_type::YAML_SCALAR_EVENT, "type";
    is $event->data->scalar->plain_implicit, 1, "plain_implicit";
    is $event->data->scalar->quoted_implicit, 1, "plain_implicit";
    is $event->data->scalar->style, $style, "scalar style";
    is $event->start_mark, "Mark(0):[L:0 C:0]", "start_mark";
#    is $event->data->scalar->val_str, "lala", "value";
};

diag "=================== END ===============";

done_testing;
