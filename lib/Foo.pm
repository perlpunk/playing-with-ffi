package Foo;

use strict;
use warnings;
use experimental 'signatures';
use FFI::Platypus 2.00;
use FFI::C;

my $ffi = FFI::Platypus->new( api => 1 );
FFI::C->ffi($ffi);

$ffi->bundle;

package Foo::event_type {
    FFI::C->enum( yaml_event_type_t => [qw/
        NO_EVENT
        STREAM_START_EVENT STREAM_END_EVENT
        DOCUMENT_START_EVENT DOCUMENT_END_EVENT
        ALIAS_EVENT SCALAR_EVENT
        SEQUENCE_START_EVENT SEQUENCE_END_EVENT
        MAPPING_START_EVENT MAPPING_END_EVENT
    /],
    { rev => 'int', prefix => 'YAML_', package => 'Foo::event_type' }
    );
}

package Foo::YamlScalarStyle {
    FFI::C->enum( yaml_scalar_style_t => [qw/
        ANY_SCALAR_STYLE
        PLAIN_SCALAR_STYLE
        SINGLE_QUOTED_SCALAR_STYLE
        DOUBLE_QUOTED_SCALAR_STYLE
        LITERAL_SCALAR_STYLE
        FOLDED_SCALAR_STYLE
    /],
    { rev => 'int', prefix => 'YAML_', package => 'Foo::YamlScalarStyle' }
    );
}

package Foo::Scalar {
    FFI::C->struct( YAML_Scalar => [
        anchor => 'opaque',
        tag => 'opaque',
        value => 'opaque',
        length => 'size_t',
        plain_implicit => 'int',
        quoted_implicit => 'int',
        style => 'yaml_scalar_style_t',
    ]);
    sub anchor_str ($self) { $ffi->cast('opaque', 'string', $self->anchor) }
    sub tag_str ($self) { $ffi->cast('opaque', 'string', $self->tag) }
    sub value_str ($self) { $ffi->cast('opaque', 'string', $self->value) }
}

package Foo::EventData {
    FFI::C->union( yaml_event_data_t => [
        scalar => 'YAML_Scalar',
    ]);
}

package Foo::YamlMark {
    use overload
        '""' => sub { shift->as_string };
    FFI::C->struct( yaml_mark_t => [
        index => 'size_t',
        line =>'size_t',
        column => 'size_t',
    ]);
    sub as_string {
        my ($self) = @_;
        sprintf "Mark(%d):[L:%d C:%d]", $self->index, $self->line, $self->column;
    }
}

package Event {
    FFI::C->struct( yaml_event_t => [
        event_type => 'yaml_event_type_t',
        data => 'yaml_event_data_t',
        start_mark => 'yaml_mark_t',
        end_mark => 'yaml_mark_t',
    ]);
}

$ffi->attach( yaml_scalar_event_initialize => [qw/
    yaml_event_t string string string int int int yaml_scalar_style_t
/] => 'int' );

1;
