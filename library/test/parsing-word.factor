IN: temporary
USING: kernel parser sequences test words ;

DEFER: foo

": foo 2 2 + . ; parsing" eval

[ [ ] ] [ "USE: temporary foo" parse ] unit-test

": foo 2 2 + . ;" eval

[ [ POSTPONE: foo ] ] [ "USE: temporary foo" parse ] unit-test

! Test > 1 ( ) comment; only the first one should be used.
[ t ] [
    CHAR: a "IN: temporary : foo ( a ) ( b ) ;" parse drop word
    "stack-effect" word-prop member?
] unit-test
