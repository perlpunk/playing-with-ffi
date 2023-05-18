use Test2::V0;
use Foo;
use Data::Dumper;

subtest scalar => sub {
    my $event = Event->new;
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
    my $event = Event->new;
    my $style = Foo::YamlSequenceStyle::YAML_FLOW_SEQUENCE_STYLE;
    my $ret = Foo::yaml_sequence_start_event_initialize($event, "Anc", "Tag", 1, $style);
    is $event->data->sequence_start->anchor_str, 'Anc', 'anchor';
    is $event->data->sequence_start->tag_str, 'Tag', 'tag';
    is $event->data->sequence_start->implicit, 1, "quoted_implicit";
    is $event->data->sequence_start->style, $style, "style";
};

diag "=================== END ===============";

done_testing;
