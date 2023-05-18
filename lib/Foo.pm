package Foo;

use strict;
use warnings;
use experimental 'signatures';
use FFI::Platypus 2.00;
use FFI::C;

my $ffi = FFI::Platypus->new( api => 1 );
FFI::C->ffi($ffi);

$ffi->bundle;

package Foo::YamlEncoding {
    FFI::C->enum( yaml_encoding_t => [qw/
        ANY_ENCODING
        UTF8_ENCODING
        UTF16LE_ENCODING
        UTF16BE_ENCODING
    /],
    { rev => 'int', prefix => 'YAML_', package => 'Foo::YamlEncoding' }
    );
}

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

package Foo::YamlErrorType {
    FFI::C->enum( yaml_error_type_t => [qw/
    NO_ERROR
    MEMORY_ERROR
    READER_ERROR
    SCANNER_ERROR
    PARSER_ERROR
    COMPOSER_ERROR
    WRITER_ERROR
    EMITTER_ERROR
    /],
    { rev => 'int', prefix => 'YAML_', package => 'Foo::YamlErrorType' }
    );
}

package Foo::YamlParserState {
    FFI::C->enum( yaml_parser_state_t => [qw/
    PARSE_STREAM_START_STATE
    PARSE_IMPLICIT_DOCUMENT_START_STATE
    PARSE_DOCUMENT_START_STATE
    PARSE_DOCUMENT_CONTENT_STATE
    PARSE_DOCUMENT_END_STATE
    PARSE_BLOCK_NODE_STATE
    PARSE_BLOCK_NODE_OR_INDENTLESS_SEQUENCE_STATE
    PARSE_FLOW_NODE_STATE
    PARSE_BLOCK_SEQUENCE_FIRST_ENTRY_STATE
    PARSE_BLOCK_SEQUENCE_ENTRY_STATE
    PARSE_INDENTLESS_SEQUENCE_ENTRY_STATE
    PARSE_BLOCK_MAPPING_FIRST_KEY_STATE
    PARSE_BLOCK_MAPPING_KEY_STATE
    PARSE_BLOCK_MAPPING_VALUE_STATE
    PARSE_FLOW_SEQUENCE_FIRST_ENTRY_STATE
    PARSE_FLOW_SEQUENCE_ENTRY_STATE
    PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_KEY_STATE
    PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_VALUE_STATE
    PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_END_STATE
    PARSE_FLOW_MAPPING_FIRST_KEY_STATE
    PARSE_FLOW_MAPPING_KEY_STATE
    PARSE_FLOW_MAPPING_VALUE_STATE
    PARSE_FLOW_MAPPING_EMPTY_VALUE_STATE
    PARSE_END_STATE
    /],
    { rev => 'int', prefix => 'YAML_', package => 'Foo::YamlParserState' }
    );
}

package Foo::StreamStart {
    FFI::C->struct( YAML_StreamStart => [
        encoding => 'yaml_encoding_t',
   ]);
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

package Foo::SequenceStart {
    FFI::C->struct( YAML_SequenceStart => [
        anchor => 'opaque',
        tag => 'opaque',
        implicit => 'int',
        style => 'yaml_sequence_style_t',
    ]);
    sub anchor_str ($self) { $ffi->cast('opaque', 'string', $self->anchor) }
    sub tag_str ($self) { $ffi->cast('opaque', 'string', $self->tag) }
}

package Foo::EventData {
    FFI::C->union( yaml_event_data_t => [
        stream_start => 'YAML_StreamStart',
        scalar => 'YAML_Scalar',
        sequence_start => 'YAML_SequenceStart',
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

package Foo::Event {
    FFI::C->struct( yaml_event_t => [
        type => 'yaml_event_type_t',
        data => 'yaml_event_data_t',
        start_mark => 'yaml_mark_t',
        end_mark => 'yaml_mark_t',
    ]);

    sub as_string {
        my ($self) = @_;
        my $str = sprintf "(%d) ",
            $self->type;
        if ($self->type == Foo::event_type::YAML_STREAM_START_EVENT()) {
            $str .= "+STR";
        }
        elsif ($self->type == Foo::event_type::YAML_STREAM_END_EVENT()) {
            $str .= "-STR";
        }
        elsif ($self->type == Foo::event_type::YAML_DOCUMENT_START_EVENT()) {
            $str .= "+DOC";
        }
        elsif ($self->type == Foo::event_type::YAML_DOCUMENT_END_EVENT()) {
            $str .= "-DOC";
        }
        elsif ($self->type == Foo::event_type::YAML_SCALAR_EVENT()) {
            my $val = $self->data->scalar->value_str;
            my $anchor = $self->data->scalar->anchor;
            my $length = $self->data->scalar->length;
            my $plain_implicit = $self->data->scalar->plain_implicit;
            $str .= sprintf "=VAL >%s< (%d) plain_implicit: %d", $val, $length, $plain_implicit;
        }
        elsif ($self->type == Foo::event_type::YAML_SEQUENCE_START_EVENT()) {
            my $style = $self->data->sequence_start->style;
            $str .= "+SEQ";
            if ($style == Foo::YamlSequenceStyle::YAML_FLOW_SEQUENCE_STYLE()) {
                $str .= " []";
            }
        }
        return $str;
    }

}

package Foo::ParserStates {
    FFI::C->struct( YAML_Parserstates => [
        start => 'yaml_parser_state_t',
        end => 'yaml_parser_state_t',
        top => 'yaml_parser_state_t',
    ]);
}
package Foo::Parser {
    FFI::C->struct( yaml_parser_t => [
        error => 'yaml_error_type_t',
        problem => 'opaque',
        problem_offset => 'size_t',
        problem_value => 'int',
        problem_mark => 'yaml_mark_t',
        context => 'opaque',
        context_mark => 'yaml_mark_t',
# 
#      * Reader stuff
# 
        read_handler => 'opaque',
# 
        read_handler_data => 'opaque',
#     /** A pointer for passing to the read handler. */
#     void *read_handler_data;
# 
        input => 'opaque',
#     /** Standard (string or file) input data. */
#     union {
#         /** String input data. */
#         struct {
#             /** The string start pointer. */
#             const unsigned char *start;
#             /** The string end pointer. */
#             const unsigned char *end;
#             /** The string current position. */
#             const unsigned char *current;
#         } string;
# 
#         /** File input data. */
#         FILE *file;
#     } input;
# 
        eof => 'int',
# 
        buffer => 'opaque',
#     /** The working buffer. */
#     struct {
#         /** The beginning of the buffer. */
#         yaml_char_t *start;
#         /** The end of the buffer. */
#         yaml_char_t *end;
#         /** The current position of the buffer. */
#         yaml_char_t *pointer;
#         /** The last filled position of the buffer. */
#         yaml_char_t *last;
#     } buffer;
# 
        unread => 'size_t',
# 
        raw_buffer => 'opaque',
#     /** The raw buffer. */
#     struct {
#         /** The beginning of the buffer. */
#         unsigned char *start;
#         /** The end of the buffer. */
#         unsigned char *end;
#         /** The current position of the buffer. */
#         unsigned char *pointer;
#         /** The last filled position of the buffer. */
#         unsigned char *last;
#     } raw_buffer;
# 
        encoding => 'yaml_encoding_t',
#     /** The input encoding. */
#     yaml_encoding_t encoding;
# 
        offset => 'size_t',
        mark => 'yaml_mark_t',
# 
#      Scanner stuff
# 
        stream_start_produced => 'int',
        stream_end_produced => 'int',
        flow_level => 'int',
# 
        tokens => 'opaque',
#     /** The tokens queue. */
#     struct {
#         /** The beginning of the tokens queue. */
#         yaml_token_t *start;
#         /** The end of the tokens queue. */
#         yaml_token_t *end;
#         /** The head of the tokens queue. */
#         yaml_token_t *head;
#         /** The tail of the tokens queue. */
#         yaml_token_t *tail;
#     } tokens;
# 
        tokens_parsed => 'size_t',
        token_available => 'int',
# 
        indents => 'opaque',
#     /** The indentation levels stack. */
#     struct {
#         /** The beginning of the stack. */
#         int *start;
#         /** The end of the stack. */
#         int *end;
#         /** The top of the stack. */
#         int *top;
#     } indents;
# 
        indent => 'int',
        simple_key_allowed => 'int',
# 
        simple_keys => 'opaque',
#     /** The stack of simple keys. */
#     struct {
#         /** The beginning of the stack. */
#         yaml_simple_key_t *start;
#         /** The end of the stack. */
#         yaml_simple_key_t *end;
#         /** The top of the stack. */
#         yaml_simple_key_t *top;
#     } simple_keys;
# 
#      * Parser stuff
# 
        states => 'opaque',
#     struct {
#         /** The beginning of the stack. */
#         yaml_parser_state_t *start;
#         /** The end of the stack. */
#         yaml_parser_state_t *end;
#         /** The top of the stack. */
#         yaml_parser_state_t *top;
#     } states;
# 
        state => 'yaml_parser_state_t',

        marks => 'opaque',
#     /** The stack of marks. */
#     struct {
#         /** The beginning of the stack. */
#         yaml_mark_t *start;
#         /** The end of the stack. */
#         yaml_mark_t *end;
#         /** The top of the stack. */
#         yaml_mark_t *top;
#     } marks;
# 
        tag_directives => 'opaque',
#     /** The list of TAG directives. */
#     struct {
#         /** The beginning of the list. */
#         yaml_tag_directive_t *start;
#         /** The end of the list. */
#         yaml_tag_directive_t *end;
#         /** The top of the list. */
#         yaml_tag_directive_t *top;
#     } tag_directives;
# 
#      Dumper stuff
# 
        aliases => 'opaque',
#     /** The alias data. */
#     struct {
#         /** The beginning of the list. */
#         yaml_alias_data_t *start;
#         /** The end of the list. */
#         yaml_alias_data_t *end;
#         /** The top of the list. */
#         yaml_alias_data_t *top;
#     } aliases;
# 
        document => 'opaque',
#     /** The currently parsed document. */
#     yaml_document_t *document;

    ]);
}

$ffi->attach( yaml_stream_start_event_initialize => [qw/
    yaml_event_t yaml_encoding_t
/] => 'int' );
$ffi->attach( yaml_scalar_event_initialize => [qw/
    yaml_event_t string string string int int int yaml_scalar_style_t
/] => 'int' );
$ffi->attach( yaml_sequence_start_event_initialize => [qw/
    yaml_event_t string string int yaml_scalar_style_t
/] => 'int' );

$ffi->attach( yaml_parser_initialize => [qw/
    yaml_parser_t
/] => 'int' );

$ffi->attach( yaml_parser_set_input_string => [qw/
    yaml_parser_t string size_t
/] => 'void' );

$ffi->attach( yaml_parser_parse => [qw/
    yaml_parser_t yaml_event_t
/] => 'int' );

$ffi->attach( yaml_event_delete => [qw/
    yaml_event_t
/] => 'void' );

$ffi->attach( yaml_parser_delete => [qw/
    yaml_parser_t
/] => 'void' );

1;
