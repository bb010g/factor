! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets gadgets-controls generic kernel models sequences ;

TUPLE: field model ;

C: field ( model -- field )
    <editor> over set-delegate
    [ set-field-model ] keep
    dup dup set-control-self ;

: field-prev dup control-model go-back editor-doc-end ;

: field-next dup control-model go-forward editor-doc-end ;

: field-commit ( field -- string )
    [ editor-text ] keep
    [ field-model [ dupd set-model ] when* ] keep
    [ control-model add-history ] keep
    select-all ;

field H{
    { T{ key-down f { C+ } "p" } [ field-prev ] }
    { T{ key-down f { C+ } "n" } [ field-next ] }
    { T{ key-down f { C+ } "k" } [ control-model clear-doc ] }
    { T{ key-down f f "RETURN" } [ field-commit drop ] }
} set-gestures
