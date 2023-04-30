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

package YAML::LibYAML::API::FFI::Scalar {
    FFI::C->struct( YAML_Scalar => [
        length => 'int',
        plain_implicit => 'int',
        quoted_implicit => 'int',
        # ???
#        anchor => 'unsigned char*',
        anchor => 'string(22)',
        tag => 'string(22)',
        value => 'string(100)',
        style => 'yaml_scalar_style_t',
    ]);
}

package YAML::LibYAML::API::FFI::EventData {
    FFI::C->union( yaml_event_data_t => [
        stream_start => 'int',
        document_end => 'int',
        scalar => 'YAML_Scalar',
    ]);
}

package Event {
    use overload
        '""' => sub { shift->as_string };
    FFI::C->struct( yaml_event_t => [
        event_type => 'yaml_event_type_t',
        data => 'yaml_event_data_t',
    ]);
    sub as_string {
        my ($self) = @_;
        sprintf "Event type: %d",
            $self->event_type;
    }
}

$ffi->attach( lala =>    [ 'yaml_event_t' ]                   => 'int'   );
$ffi->attach( yaml_scalar_event_initialize => [qw/
    yaml_event_t string string string int int int yaml_scalar_style_t
/] => 'int'   );

1;
