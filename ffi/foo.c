#include <ffi_platypus_bundle.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "yaml_private.h"
#include "yaml.h"
#include <stdint.h>


YAML_DECLARE(void *)
yaml_malloc(size_t size)
{
    return malloc(size ? size : 1);
}


YAML_DECLARE(yaml_char_t *)
yaml_strdup(const yaml_char_t *str)
{
    if (!str)
        return NULL;

    return (yaml_char_t *)strdup((char *)str);
}

static int
yaml_check_utf8(const yaml_char_t *start, size_t length)
{
    const yaml_char_t *end = start+length;
    const yaml_char_t *pointer = start;

    while (pointer < end) {
        unsigned char octet;
        unsigned int width;
        unsigned int value;
        size_t k;

        octet = pointer[0];
        width = (octet & 0x80) == 0x00 ? 1 :
                (octet & 0xE0) == 0xC0 ? 2 :
                (octet & 0xF0) == 0xE0 ? 3 :
                (octet & 0xF8) == 0xF0 ? 4 : 0;
        value = (octet & 0x80) == 0x00 ? octet & 0x7F :
                (octet & 0xE0) == 0xC0 ? octet & 0x1F :
                (octet & 0xF0) == 0xE0 ? octet & 0x0F :
                (octet & 0xF8) == 0xF0 ? octet & 0x07 : 0;
        if (!width) return 0;
        if (pointer+width > end) return 0;
        for (k = 1; k < width; k ++) {
            octet = pointer[k];
            if ((octet & 0xC0) != 0x80) return 0;
            value = (value << 6) + (octet & 0x3F);
        }
        if (!((width == 1) ||
            (width == 2 && value >= 0x80) ||
            (width == 3 && value >= 0x800) ||
            (width == 4 && value >= 0x10000))) return 0;

        pointer += width;
    }

    return 1;
}


YAML_DECLARE(int)
yaml_scalar_event_initialize(yaml_event_t *event,
        const yaml_char_t *anchor, const yaml_char_t *tag,
        const yaml_char_t *val, int length,
        int plain_implicit, int quoted_implicit,
        yaml_scalar_style_t style)
{
    fprintf(stderr, "============= yaml_scalar_event_initialize\n");
//    fprintf(stderr, "old style: %d\n", event->data.scalar.style);
    fprintf(stderr, "-> val: >%s<\n", val);
    fprintf(stderr, "-> tag: >%s<\n", tag);
    fprintf(stderr, "-> anchor: >%s<\n", anchor);
    yaml_mark_t mark = { 0, 0, 0 };
    yaml_char_t *anchor_copy = NULL;
    yaml_char_t *tag_copy = NULL;
    yaml_char_t *val_copy = NULL;

    assert(event);      /* Non-NULL event object is expected. */
    assert(val);      /* Non-NULL anchor is expected. */

    if (anchor) {
        if (!yaml_check_utf8(anchor, strlen((char *)anchor))) goto error;
        anchor_copy = yaml_strdup(anchor);
        if (!anchor_copy) goto error;
    }

    if (tag) {
        if (!yaml_check_utf8(tag, strlen((char *)tag))) goto error;
        tag_copy = yaml_strdup(tag);
        if (!tag_copy) goto error;
    }

    if (length < 0) {
        length = strlen((char *)val);
    }

    if (!yaml_check_utf8(val, length)) goto error;
    val_copy = YAML_MALLOC(length+1);
    if (!val_copy) goto error;
    memcpy(val_copy, val, length);
    val_copy[length] = '\0';

//    SCALAR_EVENT_INIT(*event, anchor_copy, tag_copy, val_copy, length,
//            plain_implicit, quoted_implicit, style, mark, mark);
    SCALAR_EVENT_INIT2(*event, anchor_copy, tag_copy, val_copy, length,
            plain_implicit, quoted_implicit, style, mark, mark);
//    fprintf(stderr, "new style: %d\n", event->data.scalar.style);
//    fprintf(stderr, "new val: >%s<\n", event->data.scalar.val);
//    fprintf(stderr, "new tag: >%s<\n", event->data.scalar.tag);
//    fprintf(stderr, "new anchor: >%s<\n", event->data.scalar.anchor);
//    fprintf(stderr, "plain_implicit: >%d<\n", event->data.scalar.plain_implicit);

    return 1;

error:
    yaml_free(anchor_copy);
    yaml_free(tag_copy);
    yaml_free(val_copy);

    return 0;
}

YAML_DECLARE(int)
yaml_sequence_start_event_initialize(yaml_event_t *event,
        const yaml_char_t *anchor, const yaml_char_t *tag, const yaml_char_t *val, int implicit,
        yaml_sequence_style_t style)
{
    size_t foo = 99;
    int length = -1;
    fprintf(stderr, "============= yaml_sequence_start_event_initialize\n");
    yaml_mark_t mark = { 0, 0, 0 };
    yaml_char_t *anchor_copy = NULL;
    yaml_char_t *tag_copy = NULL;
    yaml_char_t *val_copy = NULL;
    fprintf(stderr, "-> anchor: %s\n", anchor);
    fprintf(stderr, "-> tag: %s\n", tag);

    assert(event);      /* Non-NULL event object is expected. */

    if (anchor) {
        if (!yaml_check_utf8(anchor, strlen((char *)anchor))) goto error;
        anchor_copy = yaml_strdup(anchor);
        if (!anchor_copy) goto error;
    }

    if (tag) {
        if (!yaml_check_utf8(tag, strlen((char *)tag))) goto error;
        tag_copy = yaml_strdup(tag);
        if (!tag_copy) goto error;
    }

    if (length < 0) {
        length = strlen((char *)val);
    }
    if (foo < 0) {
        foo = strlen((char *)val);
    }
    if (!yaml_check_utf8(val, length)) goto error;
    val_copy = YAML_MALLOC(length+1);
    if (!val_copy) goto error;
    memcpy(val_copy, val, length);
    val_copy[length] = '\0';
    fprintf(stderr, "LENGTH: %d\n", length);

    SEQUENCE_START_EVENT_INIT2(*event, anchor_copy, tag_copy, val_copy,
            length, foo, implicit, style, mark, mark);


    fprintf(stderr, "new style: %d\n", event->data.sequence_start.style);
    fprintf(stderr, "new anchor: %s\n", event->data.sequence_start.anchor);
    fprintf(stderr, "new tag: %s\n", event->data.sequence_start.tag);
    return 1;

error:
    yaml_free(anchor_copy);
    yaml_free(tag_copy);

    return 0;
}



