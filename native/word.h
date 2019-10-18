typedef void (*XT)(void);

typedef struct {
	/* TAGGED header */
	CELL header;
	/* untagged hashcode */
	CELL hashcode;
	/* untagged execution token: jump here to execute word */
	CELL xt;
	/* untagged on-disk primitive number */
	CELL primitive;
	/* TAGGED parameter to xt; used for colon definitions */
	CELL parameter;
	/* TAGGED property list for library code */
	CELL plist;
	/* UNTAGGED call count incremented by profiler */
	CELL call_count;
	/* UNTAGGED amount of memory allocated in word */
	CELL allot_count;
} WORD;

INLINE WORD* untag_word(CELL tagged)
{
	type_check(WORD_TYPE,tagged);
	return (WORD*)UNTAG(tagged);
}

INLINE CELL tag_word(WORD* word)
{
	return RETAG(word,WORD_TYPE);
}

WORD* word(CELL primitive, CELL parameter, CELL plist);
void update_xt(WORD* word);
void primitive_word(void);
void primitive_word_hashcode(void);
void primitive_word_primitive(void);
void primitive_set_word_primitive(void);
void primitive_word_xt(void);
void primitive_set_word_xt(void);
void primitive_word_parameter(void);
void primitive_set_word_parameter(void);
void primitive_word_plist(void);
void primitive_set_word_plist(void);
void primitive_word_call_count(void);
void primitive_set_word_call_count(void);
void primitive_word_allot_count(void);
void primitive_set_word_allot_count(void);
void primitive_word_compiledp(void);
void fixup_word(WORD* word);
void collect_word(WORD* word);