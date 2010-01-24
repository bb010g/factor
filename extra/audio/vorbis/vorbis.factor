! (c)2010 Chris Double, Joe Groff bsd license
USING: accessors alien.c-types audio.engine byte-arrays classes.struct
combinators destructors fry gpu.buffers io kernel libc make
math math.order math.parser ogg ogg.vorbis sequences ;
IN: audio.vorbis

TUPLE: vorbis-stream < disposable
    stream
    { packet ogg-packet }
    { sync-state ogg-sync-state }
    { page ogg-page }
    { stream-state ogg-stream-state }
    { info vorbis-info }
    { dsp-state vorbis-dsp-state }
    { block vorbis-block }
    { comment vorbis-comment }
    { temp-state ogg-stream-state }
    { #vorbis-headers integer initial: 0 } ;

CONSTANT: stream-buffer-size 4096

ERROR: ogg-error code ;
ERROR: vorbis-error code ;
ERROR: no-vorbis-in-ogg ;

<PRIVATE
: init-vorbis ( vorbis-stream -- )
    [ sync-state>> ogg_sync_init drop ]
    [ info>> vorbis_info_init ]
    [ comment>> vorbis_comment_init ] tri ;

: sync-buffer ( vorbis-stream -- buffer size )
    sync-state>> stream-buffer-size ogg_sync_buffer
    stream-buffer-size ; inline

: read-bytes-into ( dest size stream -- len )
    #! Read the given number of bytes from a stream
    #! and store them in the destination byte array.
    stream-read >byte-array dup length [ memcpy ] keep  ;

: stream-into-buffer ( buffer size vorbis-stream -- len )
    stream>> read-bytes-into ; inline

: ?ogg-error ( n -- )
    dup 0 < [ ogg-error ] [ drop ] if ; inline

: confirm-buffer ( len vorbis-stream -- ? )
    '[ _ sync-state>> swap ogg_sync_wrote ?ogg-error ] keep zero? not ; inline

: buffer-data-from-stream ( vorbis-stream -- ? )
    [ sync-buffer ] [ stream-into-buffer ] [ confirm-buffer ] tri ; inline

: queue-page ( vorbis-stream -- )
    [ stream-state>> ] [ page>> ] bi ogg_stream_pagein drop ; inline

: retrieve-page ( vorbis-stream -- ? )
    [ sync-state>> ] [ page>> ] bi ogg_sync_pageout 0 > ; inline

: standard-initial-header? ( vorbis-stream -- bool )
    page>> ogg_page_bos zero? not ; inline

: ogg-stream-init ( vorbis-stream -- state )
    [ temp-state>> dup ]
    [ page>> ogg_page_serialno ogg_stream_init ?ogg-error ] bi ; inline

: ogg-stream-pagein ( state vorbis-stream -- )
    page>> ogg_stream_pagein drop ; inline

: ogg-stream-packetout ( state vorbis-stream -- )
    packet>> ogg_stream_packetout drop ; inline

: decode-packet ( vorbis-stream -- state )
    [ ogg-stream-init ] keep
    [ ogg-stream-pagein ] [ ogg-stream-packetout ] [ drop ] 2tri ; inline

: vorbis-header? ( vorbis-stream -- ? )
    [ info>> ] [ comment>> ] [ packet>> ] tri vorbis_synthesis_headerin 0 >= ; inline

: is-initial-vorbis-packet? ( vorbis-stream -- ? )
    dup #vorbis-headers>> zero? [ vorbis-header? ] [ drop f ] if ; inline

: save-initial-vorbis-header ( state vorbis-stream -- )
    [ stream-state>> swap dup byte-length memcpy ]
    [ 1 >>#vorbis-headers drop ] bi ; inline

: drop-initial-other-header ( state vorbis-stream -- )
    swap ogg_stream_clear 2drop ; inline

: process-initial-header ( vorbis-stream -- ? )
    dup standard-initial-header? [
        [ decode-packet ] keep
        dup is-initial-vorbis-packet?
        [ save-initial-vorbis-header ]
        [ drop-initial-other-header ] if
        t
    ] [ drop f ] if ;

: parse-initial-headers ( vorbis-stream -- )
    dup retrieve-page
    [ dup process-initial-header [ parse-initial-headers ] [ queue-page ] if ]
    [ dup buffer-data-from-stream [ parse-initial-headers ] [ drop ] if ] if ;

: have-required-vorbis-headers? ( vorbis-stream -- ? )
    #vorbis-headers>> 1 2 between? not ; inline

: ?vorbis-error ( code -- )
    [ vorbis-error ] unless-zero ; inline

: get-remaining-vorbis-header-packet ( player -- ? )
    [ stream-state>> ] [ packet>> ] bi ogg_stream_packetout {
        { [ dup 0 <   ] [ vorbis-error ] }
        { [ dup zero? ] [ drop f ] }
        [ drop t ]
    } cond ;

: decode-remaining-vorbis-header-packet ( vorbis-stream -- )
    [ info>> ] [ comment>> ] [ packet>> ] tri vorbis_synthesis_headerin ?vorbis-error ;

: parse-remaining-vorbis-headers ( vorbis-stream -- )
    dup have-required-vorbis-headers? not [
        dup get-remaining-vorbis-header-packet [
            [ decode-remaining-vorbis-header-packet ]
            [ [ 1 + ] change-#vorbis-headers drop ]
            [ parse-remaining-vorbis-headers ] tri
        ] [ drop ] if
    ] [ drop ] if ;

: parse-remaining-headers ( vorbis-stream -- )
    dup have-required-vorbis-headers? not [
        [ parse-remaining-vorbis-headers ]
        [ dup retrieve-page [ queue-page ] [ buffer-data-from-stream drop ] if ]
        [ parse-remaining-headers ] tri
    ] [ drop ] if ;

: init-vorbis-codec ( vorbis-stream -- )
    [ [ dsp-state>> ] [ info>> ]  bi vorbis_synthesis_init drop ]
    [ [ dsp-state>> ] [ block>> ] bi vorbis_block_init drop ] bi ;

: initialize-decoder ( vorbis-stream -- )
    dup #vorbis-headers>> zero?
    [ no-vorbis-in-ogg ]
    [ init-vorbis-codec ] if ;
PRIVATE>

: <vorbis-stream> ( stream -- vorbis-stream )
    [
        vorbis-stream new-disposable
            swap >>stream
            ogg-packet malloc-struct |free >>packet
            ogg-sync-state malloc-struct |free >>sync-state
            ogg-page malloc-struct |free >>page
            ogg-stream-state malloc-struct |free >>stream-state
            vorbis-info malloc-struct |free >>info
            vorbis-dsp-state malloc-struct |free >>dsp-state
            vorbis-block malloc-struct |free >>block
            vorbis-comment malloc-struct |free >>comment
            ogg-stream-state malloc-struct |free >>temp-state
        dup {
            [ init-vorbis ]
            [ parse-initial-headers ]
            [ parse-remaining-headers ]
            [ initialize-decoder ]
        } cleave
    ] with-destructors ;

M: vorbis-stream dispose*
    {
        [ temp-state>>   [ free ] when* ]
        [ comment>>      [ free ] when* ]
        [ block>>        [ free ] when* ]
        [ dsp-state>>    [ free ] when* ]
        [ info>>         [ free ] when* ]
        [ stream-state>> [ free ] when* ]
        [ page>>         [ free ] when* ]
        [ sync-state>>   [ free ] when* ]
        [ packet>>       [ free ] when* ]
    } cleave ;

M: vorbis-stream generator-audio-format
    [ info>> channels>> ] [ drop 16 ] [ info>> rate>> ] tri ;
M: vorbis-stream generate-audio
    drop f f ;
