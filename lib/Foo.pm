package Foo;

use strict;
use warnings;
use FFI::Platypus 2.00;
use FFI::C;

my $ffi = FFI::Platypus->new( api => 2 );
FFI::C->ffi($ffi);

$ffi->type('object(Foo)' => 'foo_t');
$ffi->bundle;

package YAML::LibYAML::API::FFI::event_type {
    FFI::C->enum( yaml_event_type_t => [qw/
        NO_EVENT
        STREAM_START_EVENT STREAM_END_EVENT
        DOCUMENT_START_EVENT DOCUMENT_END_EVENT
        ALIAS_EVENT SCALAR_EVENT
        SEQUENCE_START_EVENT SEQUENCE_END_EVENT
        MAPPING_START_EVENT MAPPING_END_EVENT
    /],
    { rev => 'int', prefix => 'YAML_', package => 'YAML::LibYAML::API::FFI::event_type' }
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
package Foo::YamlEncoding {
    FFI::C->enum( yaml_encoding_t => [qw/
    YAML_ANY_ENCODING
    YAML_UTF8_ENCODING
    YAML_UTF16LE_ENCODING
    YAML_UTF16BE_ENCODING
    /],
    { rev => 'int', prefix => 'YAML_', package => 'Foo::YamlEncoding' }
    );
}

package YAML::LibYAML::API::FFI::Scalar {
    FFI::C->struct( YAML_Scalar => [
        length => 'int',
        plain_implicit => 'int',
        quoted_implicit => 'int',
        # ???
#        anchor => 'unsigned char*',
        anchor => 'string(3)',
        tag => 'string(3)',
        value => 'string(100)',
        style => 'yaml_scalar_style_t',
    ]);
}

package YAML::LibYAML::API::FFI::SequenceStart {
    FFI::C->struct( YAML_SequenceStart => [
        style => 'yaml_scalar_style_t',
    ]);
}

package YAML::LibYAML::API::FFI::EventData {
    FFI::C->union( yaml_event_data_t => [
        stream_start => 'int',
        document_end => 'int',
        scalar => 'YAML_Scalar',
        sequence_start => 'YAML_SequenceStart',
    ]);
}

package YAML::LibYAML::API::FFI::YamlMark {
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
    ]);
    sub as_string {
        my ($self) = @_;
        my $str = sprintf "##### Event(%d) ",
            $self->event_type;
        if ($self->event_type == YAML::LibYAML::API::FFI::event_type::YAML_STREAM_START_EVENT()) {
            $str .= "+STR";
        }
        elsif ($self->event_type == YAML::LibYAML::API::FFI::event_type::YAML_SCALAR_EVENT()) {
            my $value = $self->data->scalar->value;
            my $anchor = $self->data->scalar->anchor;
            my $length = $self->data->scalar->length;
            my $plain_implicit = $self->data->scalar->plain_implicit;
            $str .= sprintf "=VAL >%s< (%d) plain_implicit: %d", $value, $length, $plain_implicit;
        }
        elsif ($self->event_type == YAML::LibYAML::API::FFI::event_type::YAML_SEQUENCE_START_EVENT()) {
            my $style = $self->data->sequence_start->style;
            $str .= "+SEQ";
        }
        return $str;
    }
}

$ffi->attach( yaml_scalar_event_initialize => [qw/
    yaml_event_t string string string int int int yaml_scalar_style_t
/] => 'int' );
$ffi->attach( yaml_stream_start_event_initialize => [qw/
    yaml_event_t yaml_encoding_t
/] => 'int' );

$ffi->attach( yaml_sequence_start_event_initialize => [qw/
    yaml_event_t string string int
    yaml_sequence_style_t
/] => 'int' );

1;
