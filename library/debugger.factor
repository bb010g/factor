! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or wxithout
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: errors
USE: combinators
USE: continuations
USE: kernel
USE: logic
USE: namespaces
USE: prettyprint
USE: stack
USE: stdio
USE: strings
USE: unparser

: standard-dump ( error -- )
    "ERROR: " write error. ;

: parse-dump ( error -- )
    <%
    "parse-name" get [ "<interactive>" ] unless* % ":" %
    "line-number" get [ 1 ] unless* fixnum>str % ": " %
    %> write
    error.
    
    "line" get print
    
    <% "pos" get " " fill % "^" % %> print ;

: in-parser? ( -- ? )
    "line" get "pos" get and ;

: default-error-handler ( error -- )
    #! Print the error and return to the top level.
    in-parser? [ parse-dump ] [ standard-dump ] ifte terpri

    "Stacks have been reset." print
    ":s :r :n :c show stacks at time of error." print

    java? [ ":j shows Java stack trace." print ] when

    suspend ;

: :s ( -- ) "error-datastack"  get . ;
: :r ( -- ) "error-callstack"  get . ;
: :n ( -- ) "error-namestack"  get . ;
: :c ( -- ) "error-catchstack" get . ;