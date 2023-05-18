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

package Foo::YamlSequenceStyle {
    FFI::C->enum( yaml_sequence_style_t => [qw/
        ANY_SEQUENCE_STYLE
        BLOCK_SEQUENCE_STYLE
        FLOW_SEQUENCE_STYLE
    /],
    { rev => 'int', prefix => 'YAML_', package => 'Foo::YamlSequenceStyle' }
    );
}
package Foo::Scalar {
    FFI::C->struct( YAML_Scalar => [
        anchor => 'opaque',
        tag => 'opaque',
        val => 'string(100)',
#        val => 'opaque',        # <----------------- will make the test die very early
        length => 'int',
        plain_implicit => 'int',
        quoted_implicit => 'int',
        style => 'yaml_scalar_style_t',
    ]);
    sub anchor_str ($self) { $ffi->cast('opaque', 'string', $self->anchor) }
    sub tag_str ($self) { $ffi->cast('opaque', 'string', $self->tag) }
    sub val_str ($self) { $ffi->cast('opaque', 'string', $self->val) }
}

package Foo::SequenceStart {
    FFI::C->struct( YAML_SequenceStart => [
        anchor => 'opaque',
        tag => 'opaque',
        val => 'opaque',
        length => 'int',
        implicit => 'int',
        style => 'yaml_sequence_style_t',
    ]);
    sub anchor_str ($self) { $ffi->cast('opaque', 'string', $self->anchor) }
    sub tag_str ($self) { $ffi->cast('opaque', 'string', $self->tag) }
    sub val_str ($self) { $ffi->cast('opaque', 'string', $self->val) }
}

package Foo::EventData {
    FFI::C->union( yaml_event_data_t => [
        scalar => 'YAML_Scalar',
        sequence_start => 'YAML_SequenceStart',
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
    sub as_string {
        my ($self) = @_;
        my $str = sprintf "##### Event(%d) ",
            $self->event_type;
        if ($self->event_type == Foo::event_type::YAML_SCALAR_EVENT()) {
            my $val = $self->data->scalar->val;
            my $anchor = $self->data->scalar->anchor;
            my $length = $self->data->scalar->length;
            my $plain_implicit = $self->data->scalar->plain_implicit;
            $str .= sprintf "=VAL >%s< (%d) plain_implicit: %d", $val, $length, $plain_implicit;
        }
        elsif ($self->event_type == Foo::event_type::YAML_SEQUENCE_START_EVENT()) {
            my $style = $self->data->sequence_start->style;
            $str .= "+SEQ";
            if ($style == Foo::YamlSequenceStyle::YAML_FLOW_SEQUENCE_STYLE()) {
                $str .= " []";
            }
        }
        return $str;
    }
}

$ffi->attach( yaml_scalar_event_initialize => [qw/
    yaml_event_t string string string int int int yaml_scalar_style_t
/] => 'int' );

$ffi->attach( yaml_sequence_start_event_initialize => [qw/
    yaml_event_t string string string int
    yaml_sequence_style_t
/] => 'int' );

1;
