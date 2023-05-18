use Test2::V0;
use Foo;
use Data::Dumper;

subtest scalar => sub {
    my $event = Foo::Event->new;
    my $style = Foo::YamlScalarStyle::YAML_FOLDED_SCALAR_STYLE;
    my $ret = Foo::yaml_scalar_event_initialize($event, "Anc", "Tag", "lala", -1, 1, 1, $style);
    is $event->data->scalar->anchor_str, 'Anc', 'anchor';
    is $event->data->scalar->tag_str, 'Tag', 'tag';
    is $event->data->scalar->value_str, "lala", "value";
    is $event->data->scalar->length, 4, "length";
    is $event->data->scalar->plain_implicit, 1, "plain_implicit";
    is $event->data->scalar->quoted_implicit, 1, "quoted_implicit";
    is $event->data->scalar->style, $style, "style";
};

subtest sequence => sub {
    my $event = Foo::Event->new;
    my $style = Foo::YamlSequenceStyle::YAML_FLOW_SEQUENCE_STYLE;
    my $ret = Foo::yaml_sequence_start_event_initialize($event, "Anc", "Tag", 1, $style);
    is $event->data->sequence_start->anchor_str, 'Anc', 'anchor';
    is $event->data->sequence_start->tag_str, 'Tag', 'tag';
    is $event->data->sequence_start->implicit, 1, "quoted_implicit";
    is $event->data->sequence_start->style, $style, "style";
};

subtest streamstart => sub {
    my $event = Foo::Event->new;
    my $encoding = Foo::YamlEncoding::YAML_UTF8_ENCODING;
    my $ret = Foo::yaml_stream_start_event_initialize($event, $encoding);
    is $event->data->stream_start->encoding, $encoding, "encoding";
    my $type = Foo::event_type::YAML_STREAM_START_EVENT;
    is $event->type, $type, "type";
};

diag "=================== END ===============";

done_testing;
