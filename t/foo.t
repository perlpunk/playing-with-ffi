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

diag "=================== END ===============";

done_testing;
