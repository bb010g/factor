IN: scratchpad
USE: init
USE: namespaces
USE: test

[
    [ f ] [ "-no-user-init" cli-arg ] unit-test
    [ f ] [ "user-init" get ] unit-test

    [ f ] [ "-user-init" cli-arg ] unit-test
    [ t ] [ "user-init" get ] unit-test
    
    [ "sdl.factor" ] [ "sdl.factor" cli-arg ] unit-test
] with-scope