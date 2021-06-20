// Helper macros to aid in optimizing lazy instantiation of lists.
// All of these are null-safe, you can use them without knowing if the list var is initialized yet

//Picks from the list, with some safeties, and returns the "default" arg if it fails
#define DEFAULTPICK(L, default) ((istype(L, /list) && L:len) ? pick(L) : default)

// Ensures L is initailized after this point
#define LAZYINITLIST(L) if (!L) L = list()

// Sets a L back to null iff it is empty
#define UNSETEMPTY(L) if (L && !length(L)) L = null

// Removes I from list L, and sets I to null if it is now empty
#define LAZYREMOVE(L, I) if(L) { L -= I; if(!length(L)) { L = null; } }

// Adds I to L, initalizing L if necessary
#define LAZYADD(L, I) if(!L) { L = list(); } L += I;

#define LAZYOR(L, I) if(!L) { L = list(); } L |= I;

// Adds I to L, initalizing L if necessary, if I is not already in L
#define LAZYDISTINCTADD(L, I) if(!L) { L = list(); } L |= I;

#define LAZYFIND(L, V) L ? L.Find(V) : 0

// Reads I from L safely - Works with both associative and traditional lists.
#define LAZYACCESS(L, I) (L ? (isnum(I) ? (I > 0 && I <= length(L) ? L[I] : null) : L[I]) : null)

// Turns LAZYINITLIST(L) L[K] = V into ...  for associated lists
#define LAZYSET(L, K, V) if(!L) { L = list(); } L[K] = V;

// Reads the length of L, returning 0 if null
#define LAZYLEN(L) length(L)

#define LAZYADDASSOC(L, K, V) if(!L) { L = list(); } L[K] += V;
///This is used to add onto lazy assoc list when the value you're adding is a /list/. This one has extra safety over lazyaddassoc because the value could be null (and thus cant be used to += objects)
#define LAZYADDASSOCLIST(L, K, V) if(!L) { L = list(); } L[K] += list(V);
#define LAZYREMOVEASSOC(L, K, V) if(L) { if(L[K]) { L[K] -= V; if(!length(L[K])) L -= K; } if(!length(L)) L = null; }
#define LAZYACCESSASSOC(L, I, K) L ? L[I] ? L[I][K] ? L[I][K] : null : null : null

// Null-safe L.Cut()
#define LAZYCLEARLIST(L) if(L) { L.Cut(); L = null; }

// Reads L or an empty list if L is not a list.  Note: Does NOT assign, L may be an expression.
#define SANITIZE_LIST(L) ( islist(L) ? L : list() )

#define reverseList(L) reverseRange(L.Copy())

// binary search sorted insert
// IN: Object to be inserted
// LIST: List to insert object into
// TYPECONT: The typepath of the contents of the list
// COMPARE: The variable on the objects to compare
#define BINARY_INSERT(IN, LIST, TYPECONT, COMPARE) \
	var/__BIN_CTTL = length(LIST);\
	if(!__BIN_CTTL) {\
		LIST += IN;\
	} else {\
		var/__BIN_LEFT = 1;\
		var/__BIN_RIGHT = __BIN_CTTL;\
		var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
		var/##TYPECONT/__BIN_ITEM;\
		while(__BIN_LEFT < __BIN_RIGHT) {\
			__BIN_ITEM = LIST[__BIN_MID];\
			if(__BIN_ITEM.##COMPARE <= IN.##COMPARE) {\
				__BIN_LEFT = __BIN_MID + 1;\
			} else {\
				__BIN_RIGHT = __BIN_MID;\
			};\
			__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
		};\
		__BIN_ITEM = LIST[__BIN_MID];\
		__BIN_MID = __BIN_ITEM.##COMPARE > IN.##COMPARE ? __BIN_MID : __BIN_MID + 1;\
		LIST.Insert(__BIN_MID, IN);\
	}

#define islist(L) istype(L, /list)

/// Passed into BINARY_INSERT to compare keys
#define COMPARE_KEY __BIN_LIST[__BIN_MID]
/// Passed into BINARY_INSERT to compare values
#define COMPARE_VALUE __BIN_LIST[__BIN_LIST[__BIN_MID]]

/**
 * Binary search sorted insert from TG
 * INPUT: Object to be inserted
 * LIST: List to insert object into
 * TYPECONT: The typepath of the contents of the list
 * COMPARE: The object to compare against, usualy the same as INPUT
 * COMPARISON: The variable on the objects to compare
 * COMPTYPE: How should the values be compared? Either COMPARE_KEY or COMPARE_VALUE.
 */
#define BINARY_INSERT_TG(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			var ##TYPECONT/__BIN_ITEM;\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(__BIN_ITEM.##COMPARISON <= COMPARE.##COMPARISON) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = __BIN_ITEM.##COMPARISON > COMPARE.##COMPARISON ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)
