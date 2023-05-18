/**
 * @file yaml.h
 * @brief Public interface for libyaml.
 * 
 * Include the header file with the code:
 * @code
 * #include <yaml.h>
 * @endcode
 */

#ifndef YAML_H
#define YAML_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/**
 * @defgroup export Export Definitions
 * @{
 */

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


YAML_DECLARE(const char *)
yaml_get_version_string(void);

YAML_DECLARE(void)
yaml_get_version(int *major, int *minor, int *patch);

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

typedef enum yaml_sequence_style_e {
    YAML_ANY_SEQUENCE_STYLE,
    YAML_BLOCK_SEQUENCE_STYLE,
    YAML_FLOW_SEQUENCE_STYLE
} yaml_sequence_style_t;

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
//            yaml_char_t *val;
            int length;
            int plain_implicit;
            int quoted_implicit;
            yaml_scalar_style_t style;
        } scalar;

        struct {
            yaml_char_t *anchor;
            yaml_char_t *tag;
            yaml_char_t *val;
            size_t length;
            int implicit;
            yaml_sequence_style_t style;
        } sequence_start;

    } data;

    yaml_mark_t start_mark;
    yaml_mark_t end_mark;

} yaml_event_t;


/** The tag @c !!null with the only possible value: @c null. */
#define YAML_NULL_TAG       "tag:yaml.org,2002:null"
/** The tag @c !!bool with the values: @c true and @c false. */
#define YAML_BOOL_TAG       "tag:yaml.org,2002:bool"
/** The tag @c !!str for string values. */
#define YAML_STR_TAG        "tag:yaml.org,2002:str"
/** The tag @c !!int for integer values. */
#define YAML_INT_TAG        "tag:yaml.org,2002:int"
/** The tag @c !!float for float values. */
#define YAML_FLOAT_TAG      "tag:yaml.org,2002:float"
/** The tag @c !!timestamp for date and time values. */
#define YAML_TIMESTAMP_TAG  "tag:yaml.org,2002:timestamp"

/** The tag @c !!seq is used to denote sequences. */
#define YAML_SEQ_TAG        "tag:yaml.org,2002:seq"
/** The tag @c !!map is used to denote mapping. */
#define YAML_MAP_TAG        "tag:yaml.org,2002:map"

/** The default scalar tag is @c !!str. */
#define YAML_DEFAULT_SCALAR_TAG     YAML_STR_TAG
/** The default sequence tag is @c !!seq. */
#define YAML_DEFAULT_SEQUENCE_TAG   YAML_SEQ_TAG
/** The default mapping tag is @c !!map. */
#define YAML_DEFAULT_MAPPING_TAG    YAML_MAP_TAG

typedef struct yaml_parser_s {

} yaml_parser_t;

#ifdef __cplusplus
}
#endif

#endif /* #ifndef YAML_H */

