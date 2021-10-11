# docker-gentoo
## Build environment for gentoo diagnostic images (https://hub.docker.com/repository/docker/hisdad/diag/general)

Gentoo is a build from source system with compile options set by USE flags. If this is new to you, then this isn't the place to start.


The objective is twofold.
1. To generate docker images that contain desired diagnostic tools.
2. To generate docker images for applications compiled with desired options.

If you are here, you have likely also seen this (https://debugged.it/blog/gentoo-docker)  which was the starting point for this work.

That was 2019, this is 2021. The issues that janos experienced are resolved.

However quirks remain.


The impetus for this came from configuring a nextcloud deployment under kubernetes.

Nginx -> php-fpm -> postgresql.   Php was unable to resolve the postgresql db hostname which was a Service.

Naturally the php image had no tools. Making a fat debian image helped, but it didn't have the correct php options.



## The procedure:

Generate a diagnostics image.
Generate a diagnostics image with php.

This pulls official gentoo images and builds out desired system.  To keep our target compiles away from the build system we "emerge" to /destination.
At at end of that, we source an empty image and copy our build /destination into it. That discards the build system

Each image is "all in one". In theory we can add to a prior image. However with the portage build system I have been unable to get consistent results even with "--no-cache".

Our build context has  pre/  .  The dockerfile  copies that.
That's  our portage build configuration and the skeleton for the target build, /destination
`
pre
|-- destination
|   |-- etc
|   |-- home
|   |-- run
|   |-- tmp
|   '-- usr
|       '-- lib
|           '-- gcc
'-- etc
    |-- locale.gen
    '-- portage
        |-- env
        |-- make.conf
        |-- package.accept_keywords
        |-- package.env
        |-- package.mask
        |   |-- php
        |   '-- rsync
        |-- package.unmask
        |-- package.use
        |   |-- 00cpu-flags
        |   |-- curl
        |   |-- gd
        |   |-- nextcloud
        |   |-- openssh
        |   |-- php
        |   |-- postgresql
        |   '-- zlib
        '-- repos.conf
            '-- gentoo.conf
`


At the end we copy post-php/ . This goes to the final image as our application configuration files (php.ini  etc).
`
		post-php
		'-- etc
				|-- group
				|-- ld.so.conf.d
				|   '-- stdc++.conf
				|-- locale.gen
				|-- passwd
				|-- php
				|   '-- fpm-php7.4
				|       |-- ext-active
				|       |-- fpm.d
				|       |   '-- www.conf
				|       |-- php-fpm.conf
				|       '-- php.ini
				'-- shadow
`


or  post-diag
`
		post-diag
		'-- etc
				|-- group
				|-- ld.so.conf.d
				|   '-- stdc++.conf
				|-- locale.gen
				|-- passwd
				'-- shadow
`



We do a bit of fiddling to generate the locale and have a  working /etc/passwd  . This is needed for the diagnostic utilites.

Janos had issues with glibc. Now it compiles fine in a ROOT 'd environment.
Janos had issues with eselect and php. Just don't bother. For an application image set the CMD or ENTRYPOINT to the binary.

Like this

`ENTRYPOINT ["/usr/lib64/php7.4/bin/php-fpm", "-F", "-c", "/etc/php/fpm-php7.4/php.ini", "-y", "/etc/php/fpm-php7.4/php-fpm.conf"]`

You will see the builds fiddling with  .so libraries. This is because some utilies are Cpp and don't use glibc. There is no such thing as glibc++.
The libraries are part of gcc and the location is version dependent. We "find" them and copy them to a fixed location. We also tell ldconfig where to look.

Thank you Janos and the gentoo team.

Enjoy.
--Dad