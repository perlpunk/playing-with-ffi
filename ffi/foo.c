#include <ffi_platypus_bundle.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "yaml_private.h"
#include "yaml.h"

/*
typedef enum yaml_event_type_e {
    YAML_NO_EVENT,
    YAML_STREAM_START_EVENT,
    YAML_STREAM_END_EVENT,
    YAML_DOCUMENT_START_EVENT,
    YAML_DOCUMENT_END_EVENT,
    YAML_ALIAS_EVENT,
    YAML_SCALAR_EVENT,
    YAML_SEQUENCE_START_EVENT,
    YAML_SEQUENCE_END_EVENT,
    YAML_MAPPING_START_EVENT,
    YAML_MAPPING_END_EVENT
} yaml_event_type_t;

typedef enum yaml_scalar_style_e {
    YAML_ANY_SCALAR_STYLE,
    YAML_PLAIN_SCALAR_STYLE,
    YAML_SINGLE_QUOTED_SCALAR_STYLE,
    YAML_DOUBLE_QUOTED_SCALAR_STYLE,
    YAML_LITERAL_SCALAR_STYLE,
    YAML_FOLDED_SCALAR_STYLE
} yaml_scalar_style_t;

typedef struct yaml_mark_s {
    size_t index;

    size_t line;

    size_t column;
} yaml_mark_t;

typedef unsigned char yaml_char_t;
typedef union {
    struct {
        int foo;
    } stream_start;
    struct {
        int bar;
    } document_end;

    struct {
        yaml_char_t *anchor;
        yaml_char_t *tag;
        yaml_char_t *value;
        size_t length;
        int plain_implicit;
        int quoted_implicit;
        yaml_scalar_style_t style;
    } scalar;
} yaml_event_data_t;


typedef struct {
  yaml_event_type_t event_type;
    union {
        struct {
            yaml_version_directive_t *version_directive;
            int implicit;
        } document_start;

        struct {
            int implicit;
        } document_end;

        struct {
            yaml_char_t *anchor;
            yaml_char_t *tag;
            yaml_char_t *value;
            size_t length;
            int plain_implicit;
            int quoted_implicit;
            yaml_scalar_style_t style;
        } scalar;

    } data;
} yaml_event_t;

*/
int
lala(yaml_event_t *event) {
    fprintf(stderr, "!!!!!!!!!!!!!!\n");
//    fprintf(stderr, "type: %d\n", event->event_type);
    return 42;
}

int
yaml_scalar_event_initialize(
    yaml_event_t *event, const yaml_char_t *anchor, const yaml_char_t *tag,
    const yaml_char_t *value, int length,
    int plain_implicit, int quoted_implicit,
    yaml_scalar_style_t style

) {
    fprintf(stderr, "============= yaml_scalar_event_initialize\n");
    fprintf(stderr, "old style: %d\n", event->data.scalar.style);
    fprintf(stderr, "anchor: %s\n", anchor);
    fprintf(stderr, "tag: %s\n", tag);
    fprintf(stderr, "value: %s\n", value);
    fprintf(stderr, "length: %d\n", length);
    fprintf(stderr, "plain_implicit: %d\n", plain_implicit);
    fprintf(stderr, "quoted_implicit: %d\n", quoted_implicit);
    fprintf(stderr, "style: %d\n", style);
    fprintf(stderr, "new style: %d\n", event->data.scalar.style);
    return 23;
}

/*
int
yaml_scalar_event_initialize2(yaml_event_t *event,
        const yaml_char_t *anchor, const yaml_char_t *tag,
        const yaml_char_t *value, int length,
        int plain_implicit, int quoted_implicit,
        yaml_scalar_style_t style)
{
//    yaml_mark_t mark = { 0, 0, 0 };
    yaml_char_t *anchor_copy = NULL;
    yaml_char_t *tag_copy = NULL;
    yaml_char_t *value_copy = NULL;

    assert(event);
    assert(value);

    if (anchor) {
//        if (!yaml_check_utf8(anchor, strlen((char *)anchor))) goto error;
        anchor_copy = yaml_strdup(anchor);
        if (!anchor_copy) goto error;
    }

    if (tag) {
        if (!yaml_check_utf8(tag, strlen((char *)tag))) goto error;
        tag_copy = yaml_strdup(tag);
        if (!tag_copy) goto error;
    }

    if (length < 0) {
        length = strlen((char *)value);
    }

    if (!yaml_check_utf8(value, length)) goto error;
    value_copy = YAML_MALLOC(length+1);
    if (!value_copy) goto error;
    memcpy(value_copy, value, length);
    value_copy[length] = '\0';

    SCALAR_EVENT_INIT(*event, anchor_copy, tag_copy, value_copy, length,
            plain_implicit, quoted_implicit, style );

    return 1;

error:
    yaml_free(anchor_copy);
    yaml_free(tag_copy);
    yaml_free(value_copy);

    return 0;
}
*/

