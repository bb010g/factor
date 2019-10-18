#include "factor.h"

void primitive_exit(void)
{
	exit(to_fixnum(dpop()));
}

void primitive_os_env(void)
{
	char* name = unbox_c_string();
	char* value = getenv(name);
	if(value == NULL)
		dpush(F);
	else
		box_c_string(getenv(name));
}

void primitive_eq(void)
{
	dpush(tag_boolean(dpop() == dpop()));
}

void primitive_millis(void)
{
	struct timeval t;
	gettimeofday(&t,NULL);
	dpush(tag_object(s48_long_long_to_bignum(
		(long long)t.tv_sec * 1000 + t.tv_usec/1000)));
}

void primitive_init_random(void)
{
#ifdef HAVE_SRANDOMDEV
	srandomdev();
#else
	struct timeval t;
	gettimeofday(&t,NULL);
	srandom(t.tv_sec);
#endif
}

void primitive_random_int(void)
{
	dpush(tag_object(s48_long_to_bignum(random())));
}

void primitive_dump(void)
{
	/* Take an object, and print its memory. Later, return a vector */
	CELL obj = dpop();
	CELL size = object_size(obj);
	int i;
	for(i = 0; i < size; i += CELLS)
		fprintf(stderr,"%lx\n",get(UNTAG(obj) + i));
}