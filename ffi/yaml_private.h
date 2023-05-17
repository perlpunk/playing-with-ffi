#if HAVE_CONFIG_H
#include "config.h"
#endif

#include "yaml.h"

#include <assert.h>
#include <limits.h>
#include <stddef.h>

/*
 * Memory management.
 */

YAML_DECLARE(void *)
yaml_malloc(size_t size);

YAML_DECLARE(void *)
yaml_realloc(void *ptr, size_t size);

YAML_DECLARE(void)
yaml_free(void *ptr);

YAML_DECLARE(yaml_char_t *)
yaml_strdup(const yaml_char_t *);

/*
 * String management.
 */

typedef struct {
    yaml_char_t *start;
    yaml_char_t *end;
    yaml_char_t *pointer;
} yaml_string_t;

YAML_DECLARE(int)
yaml_string_extend(yaml_char_t **start,
        yaml_char_t **pointer, yaml_char_t **end);

YAML_DECLARE(int)
yaml_string_join(
        yaml_char_t **a_start, yaml_char_t **a_pointer, yaml_char_t **a_end,
        yaml_char_t **b_start, yaml_char_t **b_pointer, yaml_char_t **b_end);

/*
 * Event initializers.
 */

#define EVENT_INIT(event,event_type,event_start_mark,event_end_mark)            \
    (memset(&(event), 0, sizeof(yaml_event_t)),                                 \
     (event).type = (event_type),                                               \
     (event).start_mark = (event_start_mark),                                   \
     (event).end_mark = (event_end_mark))

#define STREAM_START_EVENT_INIT(event,event_encoding,start_mark,end_mark)       \
    (EVENT_INIT((event),YAML_STREAM_START_EVENT,(start_mark),(end_mark)),       \
     (event).data.stream_start.encoding = (event_encoding))

#define DOCUMENT_END_EVENT_INIT(event,event_implicit,start_mark,end_mark)       \
    (EVENT_INIT((event),YAML_DOCUMENT_END_EVENT,(start_mark),(end_mark)),       \
     (event).data.document_end.implicit = (event_implicit))

#define SCALAR_EVENT_INIT(event,event_anchor,event_tag,event_value,event_length,    \
        event_plain_implicit,event_quoted_implicit,event_style,start_mark,end_mark)    \
    (EVENT_INIT((event),YAML_SCALAR_EVENT,(start_mark),(end_mark)),             \
     (event).data.scalar.anchor = (event_anchor),                               \
     (event).data.scalar.tag = (event_tag),                                     \
     (event).data.scalar.value = (event_value),                                 \
     (event).data.scalar.length = (event_length),                               \
     (event).data.scalar.plain_implicit = (event_plain_implicit),               \
     (event).data.scalar.quoted_implicit = (event_quoted_implicit),             \
     (event).data.scalar.style = (event_style))

#define SCALAR_EVENT_INIT2(event,event_anchor,event_tag,event_length,    \
        event_plain_implicit,event_quoted_implicit,event_style,start_mark,end_mark)    \
    (EVENT_INIT((event),YAML_SCALAR_EVENT,(start_mark),(end_mark)),             \
     (event).data.scalar.anchor = (event_anchor),                               \
     (event).data.scalar.tag = (event_tag),                                     \
     (event).data.scalar.length = (event_length),                               \
     (event).data.scalar.plain_implicit = (event_plain_implicit),               \
     (event).data.scalar.quoted_implicit = (event_quoted_implicit),             \
     (event).data.scalar.style = (event_style))

#define SEQUENCE_START_EVENT_INIT(event,event_anchor,event_tag,                 \
        event_implicit,event_style,start_mark,end_mark)                         \
    (EVENT_INIT((event),YAML_SEQUENCE_START_EVENT,(start_mark),(end_mark)),     \
     (event).data.sequence_start.anchor = (event_anchor),                       \
     (event).data.sequence_start.tag = (event_tag),                             \
     (event).data.sequence_start.implicit = (event_implicit),                   \
     (event).data.sequence_start.style = (event_style))

#define SEQUENCE_START_EVENT_INIT2(event,event_anchor,event_tag,event_val,                 \
        event_implicit,event_style,start_mark,end_mark)                         \
    (EVENT_INIT((event),YAML_SEQUENCE_START_EVENT,(start_mark),(end_mark)),     \
     (event).data.sequence_start.anchor = (event_anchor),                       \
     (event).data.sequence_start.tag = (event_tag),                             \
     (event).data.sequence_start.val = (event_val),                             \
     (event).data.sequence_start.implicit = (event_implicit),                   \
     (event).data.sequence_start.style = (event_style))


/* Strict C compiler warning helpers */

#if defined(__clang__) || defined(__GNUC__)
#  define HASATTRIBUTE_UNUSED
#endif
#ifdef HASATTRIBUTE_UNUSED
#  define __attribute__unused__             __attribute__((__unused__))
#else
#  define __attribute__unused__
#endif

/* Shim arguments are arguments that must be included in your function,
 * but serve no purpose inside.  Silence compiler warnings. */
#define SHIM(a) /*@unused@*/ a __attribute__unused__

/* UNUSED_PARAM() marks a shim argument in the body to silence compiler warnings */
#ifdef __clang__
#  define UNUSED_PARAM(a) (void)(a);
#else
#  define UNUSED_PARAM(a) /*@-noeffect*/if (0) (void)(a)/*@=noeffect*/;
#endif

#define YAML_MALLOC_STATIC(type) (type*)yaml_malloc(sizeof(type))
#define YAML_MALLOC(size)        (yaml_char_t *)yaml_malloc(size)
