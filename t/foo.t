use Test2::V0;
use Foo;
use Data::Dumper;

my $val = { event_type => YAML::LibYAML::API::FFI::event_type::YAML_SCALAR_EVENT };
my $c = Event->new($val);
diag $c->as_string;


my $style = Foo::YamlScalarStyle::YAML_LITERAL_SCALAR_STYLE;
$style = Foo::YamlScalarStyle::YAML_FOLDED_SCALAR_STYLE;
my $event = Event->new({
    event_type => YAML::LibYAML::API::FFI::event_type::YAML_SCALAR_EVENT,
    data => {
        scalar => {
            length => 3,
            plain_implicit => 1,
            quoted_implicit => 1,
            tag => 'abc',
            anchor => 'def',
            style => 0,
            value => 'abcd',
        },
    },
});
my $new_event = Event->new;

my $stream_start = Event->new;
Foo::yaml_stream_start_event_initialize($stream_start, 0);
diag $stream_start->as_string;

my $ret = Foo::yaml_scalar_event_initialize($new_event, "Anc", "Tag", "lala", -1, 1, 0, $style);
warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$ret], ['ret']);
diag $new_event->as_string;
diag $new_event->data->scalar->style;
diag $new_event->data->scalar->value;
is $new_event->data->scalar->value, "lala", "value";
is $new_event->data->scalar->style, $style, "scalar style";
is $new_event->start_mark, "Mark(0):[L:0 C:0]", "start_mark";


pass '\o/';
done_testing;
