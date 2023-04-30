use Test2::V0;
use Foo;
use Data::Dumper;

my $val = { event_type => YAML::LibYAML::API::FFI::event_type::YAML_SCALAR_EVENT };
my $c = Event->new($val);
diag $c;

my $new_color = Event->new;
my $ret = Foo::lala($new_color);
diag $new_color;

my $style = Foo::YamlScalarStyle::YAML_LITERAL_SCALAR_STYLE;
my $event = Event->new({
    event_type => YAML::LibYAML::API::FFI::event_type::YAML_SCALAR_EVENT,
    data => {
        scalar => {
            length => 3,
            plain_implicit => 1,
            quoted_implicit => 1,
            tag => 'abc',
            anchor => 'def',
            style => $style,
        },
    },
});

$ret = Foo::yaml_scalar_event_initialize($event, "Anchor", "Tag", "lala", -1, 1, 0, $style);
diag $event->data->scalar->style;

pass '\o/';
done_testing;
