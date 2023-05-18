use Test2::V0;
use Foo;
use Data::Dumper;

subtest scalar => sub {
    my $event = Event->new;
    my $style = Foo::YamlScalarStyle::YAML_FOLDED_SCALAR_STYLE;
    my $ret = Foo::yaml_scalar_event_initialize($event, "Anc", "Tag", "lala", -1, 1, 1, $style);
    is $event->data->bar->anchor_str, 'Anc', 'anchor';
    is $event->data->bar->tag_str, 'Tag', 'tag';
    is $event->data->bar->val_str, "lala", "value";
};

diag "=================== END ===============";

done_testing;
