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

Generate glibc image -> Add Diagnostics -> Add Application.  Each has a dockerfile and shell script.

We run a build with dockerfile-glibc as our starting point.

This pulls official gentoo images and builds glibc. To keep our target compiles away from the build system we "emerge" to /destination.
This takes about 15 mins.

We run a build with dockerfile-diag, which uses the prior glibc image as a source. 

The result is a fully usable diagnostic image but its about 1.2Gb

We run a build with dockerfile-php,  which uses the prior diag image as a source.
This takes about 40mins as it pulls in lots of stuff.

At at end of that, we source an empty image and copy our build /destination into it.

That is our php image with our diagnostics, about 300Mb.

Our build context has  pre/  .  The dockerfile-glibc copies that. That's (mostly) our portage build configuration. Later images inherit it.

		pre/
		-- etc
				|-- locale.gen
				- portage
						|-- env
						|-- make.conf
						|-- package.accept_keywords
						|-- package.env
						|-- package.mask
						|   |-- php
						|   |-- rsync
						|-- package.unmask
						|-- package.use
						|   |-- 00cpu-flags
						|   |-- curl
						|   |-- gd
						|   |-- nextcloud
						|   |-- openssh
						|   |-- php
						|   |-- postgresql
						|   |-- zlib
						|-- repos.conf
							  |-- gentoo.conf


To set up glibc we copy

		post-glibc/
		|-- etc
				|-- group
				|-- ld.so.conf.d
				|   |-- stdc++.conf
				|-- locale.gen
				|-- passwd
				|-- shadow



At the end we copy post-php/ . This goes to the final image as our application configuration files (php.ini  etc), Empty here


We do a bit of fiddling to generate the locale and have a  working /etc/passwd  . This is needed for the diagnostic utilites.

Janos had issues with glibc. Now it compiles fine in a ROOT 'd environment
Janos had issues with eselect and php. Just don't bother. For an application image set the CMD or ENTRYPOINT to the binary.

Like this

`ENTRYPOINT ["/usr/lib64/php7.4/bin/php-fpm", "-F", "-c", "/etc/php/fpm-php7.4/php.ini", "-y", "/etc/php/fpm-php7.4/php-fpm.conf"]`

You will see the glibc build fiddling with  .so libraries. This is because some utilies are Cpp and don't use glibc. There is no such thing as glibc++.
The libraries are part of gcc and the location is version dependent. We "find" them and copy them to a fixed location. We also tell ldconfig where to look.


Thankyou Janos and the gentoo team.

Enjoy.
--Dad