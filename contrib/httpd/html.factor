! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: html
USING: generic hashtables http io kernel lists math namespaces
sequences strings styles words ;

: html-entities ( -- alist )
    H{
        { CHAR: < "&lt;"   }
        { CHAR: > "&gt;"   }
        { CHAR: & "&amp;"  }
        { CHAR: ' "&apos;" }
        { CHAR: " "&quot;" }
    } ;

: chars>entities ( str -- str )
    #! Convert <, >, &, ' and " to HTML entities.
    [
        [ dup html-entities hash [ % ] [ , ] ?if ] each
    ] "" make ;

: hex-color, ( triplet -- )
    3 swap head [ 255 * >fixnum >hex 2 CHAR: 0 pad-left % ] each ;

: fg-css, ( color -- )
    "color: #" % hex-color, "; " % ;

: style-css, ( flag -- )
    dup [ italic bold-italic ] member?
    [ "font-style: italic; " % ] when
    [ bold bold-italic ] member?
    [ "font-weight: bold; " % ] when ;

: underline-css, ( flag -- )
    [ "text-decoration: underline; " % ] when ;

: size-css, ( size -- )
    "font-size: " % # "; " % ;

: font-css, ( font -- )
    "font-family: " % % "; " % ;

: hash-apply ( value-hash quot-hash -- )
    #! Looks up the key of each pair in the first list in the
    #! second list to produce a quotation. The quotation is
    #! applied to the value of the pair. If there is no
    #! corresponding quotation, the value is popped off the
    #! stack.
    swap [
        swap rot hash dup [ call ] [ 2drop ] if
    ] hash-each-with ;

: css-style ( style -- )
    [
        H{
            { foreground  [ fg-css,        ] }
            { font        [ font-css,      ] }
            { font-style  [ style-css,     ] }
            { font-size   [ size-css,      ] }
            { underline   [ underline-css, ] }
        } hash-apply
    ] "" make ;

: span-tag ( style quot -- )
    over css-style dup "" = [
        drop call
    ] [
        <span =style span> call </span>
    ] if ;

: resolve-file-link ( path -- link )
    #! The file responder needs relative links not absolute
    #! links.
    "doc-root" get [
        ?head [ "/" ?head drop ] when
    ] when* "/" ?tail drop ;

: file-link-href ( path -- href )
    [ "/" % resolve-file-link url-encode % ] "" make ;

: file-link-tag ( style quot -- )
    over file swap hash [
        <a file-link-href =href a> call </a>
    ] [
        call
    ] if* ;

: browser-link-href ( word -- href )
    dup word-name swap word-vocabulary
    [
        "/responder/browser/?vocab=" %
        url-encode %
        "&word=" %
        url-encode %
    ] "" make ;

: browser-link-tag ( style quot -- style )
    over presented swap hash dup word? [
        <a browser-link-href =href a> call </a>
    ] [
        drop call
    ] if ;

TUPLE: wrapper-stream scope ;

C: wrapper-stream ( stream -- stream )
    2dup set-delegate [
        >r stdio associate r> set-wrapper-stream-scope
    ] keep ;

: with-wrapper ( stream quot -- )
    >r wrapper-stream-scope r> bind ; inline

TUPLE: html-stream ;

M: html-stream stream-write1 ( char stream -- )
    [
        dup html-entities hash [ write ] [ write1 ] ?if
    ] with-wrapper ;

M: html-stream stream-format ( str style stream -- )
    [
        [
            [
                [ drop chars>entities write ] span-tag
            ] file-link-tag
        ] browser-link-tag
    ] with-wrapper ;

C: html-stream ( stream -- stream )
    #! Wraps the given stream in an HTML stream. An HTML stream
    #! converts special characters to entities when being
    #! written, and supports writing attributed strings with
    #! the following attributes:
    #!
    #! foreground - an rgb triplet in a list
    #! background - an rgb triplet in a list
    #! font
    #! font-style
    #! font-size
    #! underline
    #! file
    #! word
    #! vocab
    [ >r <wrapper-stream> r> set-delegate ] keep ;

: with-html-stream ( quot -- )
    [ stdio [ <html-stream> ] change  call ] with-scope ;

: html-document ( title quot -- )
    swap chars>entities dup
    <html>
        <head>
            <title> write </title>
        </head>
        <body>
            <h1> write </h1>
            call
        </body>
    </html> ;

: simple-html-document ( title quot -- )
    swap [ <pre> with-html-stream </pre> ] html-document ;
