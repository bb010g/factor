! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.linearization compiler.cfg.liveness compiler.cfg.registers
compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.renaming.functor
compiler.cfg.ssa.destruction.leaders cpu.architecture
fry heaps kernel locals make math namespaces sequences sets ;
FROM: namespaces => set ;
IN: compiler.cfg.linear-scan.assignment

! This contains both active and inactive intervals; any interval
! such that start <= insn# <= end is in this set.
SYMBOL: pending-interval-heap
SYMBOL: pending-interval-assoc

: add-pending ( live-interval -- )
    [ dup end>> pending-interval-heap get heap-push ]
    [ [ reg>> ] [ vreg>> ] bi pending-interval-assoc get set-at ]
    bi ;

: remove-pending ( live-interval -- )
    vreg>> pending-interval-assoc get delete-at ;

:: vreg>reg ( vreg -- reg )
    vreg leader :> leader
    leader pending-interval-assoc get at* [
        drop leader vreg rep-of lookup-spill-slot
    ] unless ;

ERROR: not-spilled-error vreg ;

: vreg>spill-slot ( vreg -- spill-slot )
    dup vreg>reg dup spill-slot? [ nip ] [ drop leader not-spilled-error ] if ;

: vregs>regs ( vregs -- assoc )
    [ f ] [ [ dup vreg>reg ] H{ } map>assoc ] if-empty ;

SYMBOL: unhandled-intervals

: init-unhandled ( live-intervals -- unhandled-intervals  )
    [ dup start>> swap 2array ] map >min-heap  ;

! Liveness info is used by resolve pass
SYMBOL: machine-live-ins

: machine-live-in ( bb -- assoc )
    machine-live-ins get at ;

: compute-live-in ( bb -- )
    [ live-in keys vregs>regs ] keep machine-live-ins get set-at ;

! Mapping from basic blocks to predecessors to values which are
! live on a particular incoming edge
SYMBOL: machine-edge-live-ins

: machine-edge-live-in ( predecessor bb -- assoc )
    machine-edge-live-ins get at at ;

: compute-edge-live-in ( bb -- )
    [ edge-live-ins get at [ keys vregs>regs ] assoc-map ] keep
    machine-edge-live-ins get set-at ;

SYMBOL: machine-live-outs

: machine-live-out ( bb -- assoc )
    machine-live-outs get at ;

: compute-live-out ( bb -- )
    [ live-out keys vregs>regs ] keep machine-live-outs get set-at ;

: init-assignment ( live-intervals -- )
    init-unhandled unhandled-intervals set
    <min-heap> pending-interval-heap set
    H{ } clone pending-interval-assoc set
    H{ } clone machine-live-ins set
    H{ } clone machine-edge-live-ins set
    H{ } clone machine-live-outs set ;

: insert-spill ( live-interval -- )
    [ reg>> ] [ spill-rep>> ] [ spill-to>> ] tri ##spill, ;

: handle-spill ( live-interval -- )
    dup spill-to>> [ insert-spill ] [ drop ] if ;

: expire-interval ( live-interval -- )
    [ remove-pending ] [ handle-spill ] bi ;

: (expire-old-intervals) ( n heap -- )
    dup heap-empty? [ 2drop ] [
        2dup heap-peek nip <= [ 2drop ] [
            dup heap-pop drop expire-interval
            (expire-old-intervals)
        ] if
    ] if ;

: expire-old-intervals ( n -- )
    pending-interval-heap get (expire-old-intervals) ;

: insert-reload ( live-interval -- )
    [ reg>> ] [ reload-rep>> ] [ reload-from>> ] tri ##reload, ;

: handle-reload ( live-interval -- )
    dup reload-from>> [ insert-reload ] [ drop ] if ;

: activate-interval ( live-interval -- )
    [ add-pending ] [ handle-reload ] bi ;

: (activate-new-intervals) ( n heap -- )
    dup heap-empty? [ 2drop ] [
        2dup heap-peek nip = [
            dup heap-pop drop activate-interval
            (activate-new-intervals)
        ] [ 2drop ] if
    ] if ;

: activate-new-intervals ( n -- )
    unhandled-intervals get (activate-new-intervals) ;

: prepare-insn ( n -- )
    [ expire-old-intervals ] [ activate-new-intervals ] bi ;

GENERIC: assign-registers-in-insn ( insn -- )

RENAMING: assign [ vreg>reg ] [ vreg>reg ] [ vreg>reg ]

M: vreg-insn assign-registers-in-insn
    [ assign-insn-defs ] [ assign-insn-uses ] [ assign-insn-temps ] tri ;

: assign-gc-roots ( gc-map -- )
    [ [ vreg>spill-slot ] map ] change-gc-roots drop ;

: assign-derived-roots ( gc-map -- )
    [ [ [ vreg>spill-slot ] bi@ ] assoc-map ] change-derived-roots drop ;

M: gc-map-insn assign-registers-in-insn
    [ [ assign-insn-defs ] [ assign-insn-uses ] [ assign-insn-temps ] tri ]
    [ gc-map>> [ assign-gc-roots ] [ assign-derived-roots ] bi ]
    bi ;

M: insn assign-registers-in-insn drop ;

: begin-block ( bb -- )
    {
        [ basic-block set ]
        [ block-from activate-new-intervals ]
        [ compute-edge-live-in ]
        [ compute-live-in ]
    } cleave ;

:: assign-registers-in-block ( bb -- )
    bb [
        [
            bb begin-block
            [
                {
                    [ insn#>> 1 - prepare-insn ]
                    [ insn#>> prepare-insn ]
                    [ assign-registers-in-insn ]
                    [ , ]
                } cleave
            ] each
            bb compute-live-out
        ] V{ } make
    ] change-instructions drop ;

: assign-registers ( live-intervals cfg -- )
    [ init-assignment ] dip
    linearization-order [ kill-block?>> not ] filter
    [ assign-registers-in-block ] each ;
