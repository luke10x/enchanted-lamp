# Debugging PHP with GDB

At its center it has a PHP application, which is a simple Wordpress site,
and its supporting infrastructure.

## Sandbox Environment

The environment is managed by Docker Compose, therefore use `docker-compose up -d`
to start it, it will start Nginx, php-fpm and MySql services.

Use `docker-compose down` to shutdown the environment.

## Demo 

Lock the DB with:

    make mysql-lock-post

Try to edit the locked post:

    make client-edit-post

Check which PHP worker is processing the locked connection:

    make wordpress-connected-to | grep ESTA

It will print something like

    tcp        0      0 172.19.0.5:41128        172.19.0.6:3306         ESTABLISHED 25889/php-fpm: pool 
    tcp6       8      0 172.19.0.5:9000         172.19.0.2:37314        ESTABLISHED 25889/php-fpm: pool

Which means that worker Pid is `25889`.
So we can connect the debugger:

    sudo gdb -p 25889

Then in the `(gdb)` prompt type:

    source .gdbinit

Current backtrace will be printed...

## Generate core dumps on segfaults

Cores are dumped by kernel, therefore the kernel
needs to be configured on how and where to dump cores:

    echo '/tmp/cores/core.%e.%p.%t' > /proc/sys/kernel/core_pattern
    echo 0 > /proc/sys/kernel/core_uses_pid
    echo 1 > /proc/sys/fs/suid_dumpable

Also Selinux must allow it:

    getsebool allow_daemons_dump_core

## VNC client:

Web URLs are not accessed from outside of the Docker network.
However, it is possible to connect to the chrome container with VNC client.
From there it is possible to open the following URLs:
Connect t
- The public [website](http://wordpress-sandbox.discoverops.com);
- Wordpress [admin panel](http://wordpress-sandbox.discoverops.com/wp-admin/), login with `root`:`password`;
