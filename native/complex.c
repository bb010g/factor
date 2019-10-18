#include "factor.h"

void primitive_real(void)
{
	switch(type_of(dpeek()))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
	case RATIO_TYPE:
		/* No op */
		break;
	case COMPLEX_TYPE:
		drepl(untag_complex(dpeek())->real);
		break;
	default:
		type_error(NUMBER_TYPE,dpeek());
		break;
	}
}

void primitive_imaginary(void)
{
	switch(type_of(dpeek()))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
	case RATIO_TYPE:
		drepl(tag_fixnum(0));
		break;
	case COMPLEX_TYPE:
		drepl(untag_complex(dpeek())->imaginary);
		break;
	default:
		type_error(NUMBER_TYPE,dpeek());
		break;
	}
}

void primitive_to_rect(void)
{
	COMPLEX* c;
	switch(type_of(dpeek()))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
	case RATIO_TYPE:
		dpush(tag_fixnum(0));
		break;
	case COMPLEX_TYPE:
		c = untag_complex(dpop());
		dpush(c->real);
		dpush(c->imaginary);
		break;
	default:
		type_error(NUMBER_TYPE,dpeek());
		break;
	}
}

void primitive_from_rect(void)
{
	CELL imaginary = dpop();
	CELL real = dpop();

	if(!realp(imaginary))
		type_error(REAL_TYPE,imaginary);

	if(!realp(real))
		type_error(REAL_TYPE,real);

	if(zerop(imaginary))
		dpush(real);
	else
	{
		COMPLEX* complex = allot(sizeof(COMPLEX));
		complex->real = real;
		complex->imaginary = imaginary;
		dpush(tag_complex(complex));
	}
}