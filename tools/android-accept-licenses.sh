#!/usr/bin/expect -f

set timeout -1
set cmd [lindex $argv 0]
set licenses [lindex $argv 1]

spawn {*}$cmd
expect {
    \"\[y\\/n\]: \" {
        send \"y\\\r\"
        expect \"y\\\r\"
        exp_continue
    }
}
