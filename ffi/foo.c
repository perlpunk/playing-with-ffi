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

YAML_DECLARE(int)
yaml_scalar_event_initialize(yaml_event_t *event,
        const yaml_char_t *anchor, const yaml_char_t *tag,
        const yaml_char_t *val, int length,
        int plain_implicit, int quoted_implicit,
        yaml_scalar_style_t style)
{
    fprintf(stderr, "============= yaml_scalar_event_initialize\n");
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
        anchor_copy = yaml_strdup(anchor);
        if (!anchor_copy) goto error;
    }

    if (tag) {
        tag_copy = yaml_strdup(tag);
        if (!tag_copy) goto error;
    }

    if (val) {
        val_copy = yaml_strdup(val);
        if (!val_copy) goto error;
    }

//    SCALAR_EVENT_INIT(*event, anchor_copy, tag_copy, val_copy, length,
//            plain_implicit, quoted_implicit, style, mark, mark);
    SCALAR_EVENT_INIT2(*event, anchor_copy, tag_copy, val_copy,
            mark, mark);

    return 1;

error:
    yaml_free(anchor_copy);
    yaml_free(tag_copy);
    yaml_free(val_copy);

    return 0;
}

