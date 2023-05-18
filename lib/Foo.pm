package Foo;

use strict;
use warnings;
use experimental 'signatures';
use FFI::Platypus 2.00;
use FFI::C;

my $ffi = FFI::Platypus->new( api => 2 );
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

package Foo::Bar {
    FFI::C->struct( YAML_Bar => [
        anchor => 'opaque',
        tag => 'opaque',
        val => 'opaque',
    ]);
    sub anchor_str ($self) { $ffi->cast('opaque', 'string', $self->anchor) }
    sub tag_str ($self) { $ffi->cast('opaque', 'string', $self->tag) }
    sub val_str ($self) { $ffi->cast('opaque', 'string', $self->val) }
}

package Foo::EventData {
    FFI::C->union( yaml_event_data_t => [
        bar => 'YAML_Bar',
    ]);
}

package Foo::YamlMark {
    use overload
        '""' => sub { shift->as_string };
    FFI::C->struct( yaml_mark_t => [
        index => 'int',
        line =>'int',
        column => 'int',
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
