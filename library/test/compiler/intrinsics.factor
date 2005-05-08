IN: temporary
USING: compiler kernel kernel-internals lists math
math-internals test words ;

! Make sure that intrinsic ops compile to correct code.
: compile-1 ( quot -- word )
    gensym [ swap define-compound ] keep dup compile execute ;

[ 1 ] [ [[ 1 2 ]] [ 0 slot ] compile-1 ] unit-test
[ 1 ] [ [ [[ 1 2 ]] 0 slot ] compile-1 ] unit-test
[ 3 ] [ 3 1 2 cons [ [ 0 set-slot ] keep ] compile-1 car ] unit-test
[ 3 ] [ 3 1 2 [ cons [ 0 set-slot ] keep ] compile-1 car ] unit-test
[ 3 ] [ [ 3 1 2 cons [ 0 set-slot ] keep ] compile-1 car ] unit-test

[ ] [ 1 [ drop ] compile-1 ] unit-test
[ ] [ [ 1 drop ] compile-1 ] unit-test
[ ] [ [ 1 2 2drop ] compile-1 ] unit-test
[ ] [ 1 [ 2 2drop ] compile-1 ] unit-test
[ ] [ 1 2 [ 2drop ] compile-1 ] unit-test
[ 2 1 ] [ [ 1 2 swap ] compile-1 ] unit-test
[ 2 1 ] [ 1 [ 2 swap ] compile-1 ] unit-test
[ 2 1 ] [ 1 2 [ swap ] compile-1 ] unit-test
[ 1 1 ] [ 1 [ dup ] compile-1 ] unit-test
[ 1 1 ] [ [ 1 dup ] compile-1 ] unit-test
[ 1 2 1 ] [ [ 1 2 over ] compile-1 ] unit-test
[ 1 2 1 ] [ 1 [ 2 over ] compile-1 ] unit-test
[ 1 2 1 ] [ 1 2 [ over ] compile-1 ] unit-test
[ 1 2 3 1 ] [ [ 1 2 3 pick ] compile-1 ] unit-test
[ 1 2 3 1 ] [ 1 [ 2 3 pick ] compile-1 ] unit-test
[ 1 2 3 1 ] [ 1 2 [ 3 pick ] compile-1 ] unit-test
[ 1 2 3 1 ] [ 1 2 3 [ pick ] compile-1 ] unit-test
[ 1 1 2 ] [ [ 1 2 dupd ] compile-1 ] unit-test
[ 1 1 2 ] [ 1 [ 2 dupd ] compile-1 ] unit-test
[ 1 1 2 ] [ 1 2 [ dupd ] compile-1 ] unit-test

[ 4 ] [ 12 7 [ fixnum-bitand ] compile-1 ] unit-test
[ 4 ] [ 12 [ 7 fixnum-bitand ] compile-1 ] unit-test
[ 4 ] [ [ 12 7 fixnum-bitand ] compile-1 ] unit-test

[ 15 ] [ 12 7 [ fixnum-bitor ] compile-1 ] unit-test
[ 15 ] [ 12 [ 7 fixnum-bitor ] compile-1 ] unit-test
[ 15 ] [ [ 12 7 fixnum-bitor ] compile-1 ] unit-test

[ 11 ] [ 12 7 [ fixnum-bitxor ] compile-1 ] unit-test
[ 11 ] [ 12 [ 7 fixnum-bitxor ] compile-1 ] unit-test
[ 11 ] [ [ 12 7 fixnum-bitxor ] compile-1 ] unit-test

[ f ] [ 12 7 [ fixnum< ] compile-1 ] unit-test
[ f ] [ 12 [ 7 fixnum< ] compile-1 ] unit-test
[ f ] [ [ 12 7 fixnum< ] compile-1 ] unit-test
[ f ] [ [ 12 12 fixnum< ] compile-1 ] unit-test

[ t ] [ 12 70 [ fixnum< ] compile-1 ] unit-test
[ t ] [ 12 [ 70 fixnum< ] compile-1 ] unit-test
[ t ] [ [ 12 70 fixnum< ] compile-1 ] unit-test

[ f ] [ 12 7 [ fixnum<= ] compile-1 ] unit-test
[ f ] [ 12 [ 7 fixnum<= ] compile-1 ] unit-test
[ f ] [ [ 12 7 fixnum<= ] compile-1 ] unit-test
[ t ] [ [ 12 12 fixnum<= ] compile-1 ] unit-test

[ t ] [ 12 70 [ fixnum<= ] compile-1 ] unit-test
[ t ] [ 12 [ 70 fixnum<= ] compile-1 ] unit-test
[ t ] [ [ 12 70 fixnum<= ] compile-1 ] unit-test

[ t ] [ 12 7 [ fixnum> ] compile-1 ] unit-test
[ t ] [ 12 [ 7 fixnum> ] compile-1 ] unit-test
[ t ] [ [ 12 7 fixnum> ] compile-1 ] unit-test
[ f ] [ [ 12 12 fixnum> ] compile-1 ] unit-test

[ f ] [ 12 70 [ fixnum> ] compile-1 ] unit-test
[ f ] [ 12 [ 70 fixnum> ] compile-1 ] unit-test
[ f ] [ [ 12 70 fixnum> ] compile-1 ] unit-test

[ t ] [ 12 7 [ fixnum>= ] compile-1 ] unit-test
[ t ] [ 12 [ 7 fixnum>= ] compile-1 ] unit-test
[ t ] [ [ 12 7 fixnum>= ] compile-1 ] unit-test
[ t ] [ [ 12 12 fixnum>= ] compile-1 ] unit-test

[ f ] [ 12 70 [ fixnum>= ] compile-1 ] unit-test
[ f ] [ 12 [ 70 fixnum>= ] compile-1 ] unit-test
[ f ] [ [ 12 70 fixnum>= ] compile-1 ] unit-test

[ f ] [ 1 2 [ eq? ] compile-1 ] unit-test
[ f ] [ 1 [ 2 eq? ] compile-1 ] unit-test
[ f ] [ [ 1 2 eq? ] compile-1 ] unit-test
[ t ] [ 3 3 [ eq? ] compile-1 ] unit-test
[ t ] [ 3 [ 3 eq? ] compile-1 ] unit-test
[ t ] [ [ 3 3 eq? ] compile-1 ] unit-test

[ -1 ] [ 0 [ fixnum-bitnot ] compile-1 ] unit-test
[ -1 ] [ [ 0 fixnum-bitnot ] compile-1 ] unit-test

[ 3 ] [ 13 10 [ fixnum-mod ] compile-1 ] unit-test
[ 3 ] [ 13 [ 10 fixnum-mod ] compile-1 ] unit-test
[ 3 ] [ [ 13 10 fixnum-mod ] compile-1 ] unit-test
[ -3 ] [ -13 10 [ fixnum-mod ] compile-1 ] unit-test
[ -3 ] [ -13 [ 10 fixnum-mod ] compile-1 ] unit-test
[ -3 ] [ [ -13 10 fixnum-mod ] compile-1 ] unit-test

[ 4 ] [ 1 3 [ fixnum+ ] compile-1 ] unit-test
[ 4 ] [ 1 [ 3 fixnum+ ] compile-1 ] unit-test
[ 4 ] [ [ 1 3 fixnum+ ] compile-1 ] unit-test

[ t ] [ 1 27 fixnum-shift dup [ fixnum+ ] compile-1 1 28 fixnum-shift = ] unit-test
[ -268435457 ] [ 1 28 shift neg >fixnum [ -1 fixnum+ ] compile-1 ] unit-test

[ 6 ] [ 2 3 [ fixnum* ] compile-1 ] unit-test
[ 6 ] [ 2 [ 3 fixnum* ] compile-1 ] unit-test
[ 6 ] [ [ 2 3 fixnum* ] compile-1 ] unit-test
[ -6 ] [ 2 -3 [ fixnum* ] compile-1 ] unit-test
[ -6 ] [ 2 [ -3 fixnum* ] compile-1 ] unit-test
[ -6 ] [ [ 2 -3 fixnum* ] compile-1 ] unit-test

[ t ] [ 1 20 shift 1 20 shift [ fixnum* ] compile-1 1 40 shift = ] unit-test
[ t ] [ 1 20 shift neg 1 20 shift [ fixnum* ] compile-1 1 40 shift neg = ] unit-test
[ t ] [ 1 20 shift neg 1 20 shift neg [ fixnum* ] compile-1 1 40 shift = ] unit-test

[ 2 ] [ 4 2 [ fixnum/i ] compile-1 ] unit-test
[ 2 ] [ 4 [ 2 fixnum/i ] compile-1 ] unit-test
[ -2 ] [ 4 [ -2 fixnum/i ] compile-1 ] unit-test
[ 268435456 ] [ -268435456 >fixnum -1 [ fixnum/i ] compile-1 ] unit-test

[ 3 1 ] [ 10 3 [ fixnum/mod ] compile-1 ] unit-test
