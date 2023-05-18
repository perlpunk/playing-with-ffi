#ifndef YAML_H
#define YAML_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/** The public API declaration. */

#if defined(__MINGW32__)
#   define  YAML_DECLARE(type)  type
#elif defined(_WIN32)
#   if defined(YAML_DECLARE_STATIC)
#       define  YAML_DECLARE(type)  type
#   elif defined(YAML_DECLARE_EXPORT)
#       define  YAML_DECLARE(type)  __declspec(dllexport) type
#   else
#       define  YAML_DECLARE(type)  __declspec(dllimport) type
#   endif
#else
#   define  YAML_DECLARE(type)  type
#endif


typedef unsigned char yaml_char_t;

typedef struct yaml_mark_s {
    size_t index;
    size_t line;
    size_t column;
} yaml_mark_t;

typedef enum yaml_scalar_style_e {
    YAML_ANY_SCALAR_STYLE,
    YAML_PLAIN_SCALAR_STYLE,
    YAML_SINGLE_QUOTED_SCALAR_STYLE,
    YAML_DOUBLE_QUOTED_SCALAR_STYLE,
    YAML_LITERAL_SCALAR_STYLE,
    YAML_FOLDED_SCALAR_STYLE
} yaml_scalar_style_t;

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

typedef struct yaml_event_s {
    yaml_event_type_t type;
    union {
        struct {
            yaml_char_t *anchor;
            yaml_char_t *tag;
            yaml_char_t *val;
        } bar;
    } data;
    yaml_mark_t start_mark;
    yaml_mark_t end_mark;
} yaml_event_t;


#ifdef __cplusplus
}
#endif

#endif /* #ifndef YAML_H */

