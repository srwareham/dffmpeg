=======
dffmpeg 
=======

:code:`dffmpeg` is a dockerized version of :code:`ffmpeg`. With :code:`dffmpeg`, any system that supports docker can have a fully functioning version of :code:`ffmpeg` without having to install any dependencies (besides docker). 

| :code:`dffmpeg` can be considered fully portable as the steps to have a working :code:`ffmpeg` will be exactly the same across all of your systems.


Features
========

- No dependencies installed on the host system

- Drop-in replacement for a locally-installed :code:`ffmpeg` binary (for file-level commands)

- Limited to no overhead executing :code:`ffmpeg` within a docker container

- Portability across all hosts: if docker can run on your system, you can have full :code:`ffmpeg` support

- No compiling/gathering dependencies: as a turnkey solution, all you have to do is run the initial setup script to have access to :code:`ffmpeg`


Usage
=====

Once installed via the steps below, :code:`dffmpeg` is called exactly the same as :code:`ffmpeg`:

.. code-block:: bash

    $ dffmpeg -i input.mp4 -vcodec libx264 output.mp4
    $ dffmpeg -i /path/to/input.mkv -vcodec libx264 -acodec libfdk_aac /path/to/output.mkv


How Does dffmpeg Work?
======================

:code:`dffmpeg` consists of two parts:

1. A docker image that has :code:`ffmpeg` configured as its entrypoint
2. A bash executable to format :code:`ffmpeg` commands to be run via docker

dffmpeg Docker Image
--------------------

| For dockerizing :code:`ffmpeg`, :code:`ffmpeg` is installed inside of a docker image and the image's entrypoint is configured to be the installed :code:`ffmpeg` binary. 

| As part of this repository, two example implementations are provided:

1. An alpine linux docker image and its `ffmpeg <https://pkgs.alpinelinux.org/package/v3.3/main/x86/ffmpeg>`_ package
2. An Arch Linux docker image and the Arch User Repository ("AUR") package `ffmpeg-libfdk_aac <https://aur.archlinux.org/packages/ffmpeg-libfdk_aac/>`_

 
dffmpeg Executable
------------------

| :code:`dffmpeg` provides dffmpeg.sh to be used as a drop-in replacement for ffmpeg. dffmpeg.sh is called in exactly the same manner as ffmpeg, but instead of a local ffmpeg binary (with all of its installed dependencies), dffmpeg executes ffmpeg from within a docker container.

|  Any docker container with :code:`ffmpeg` as its entrypoint can be used by :code:`dffmpeg.sh` (to do so, simply change the :code:`dffmpeg_image_name` variable within :code:`dffmpeg.sh` from :code:`alpine-ffmpeg` to the name of the desired replacement image.

Installation
============

Installing :code:`dffmpeg` consists of two main steps:

1. Building a docker image that has :code:`ffmpeg` as its entrypoint; and
2. Saving :code:`dffmpeg.sh` to a path accessible by your system's :code:`$PATH`

Default Install Steps
---------------------
.. code-block:: bash

    # Download dffmpeg.sh and the Dockerfile to build the default Arch Linux image implementation
    git clone https://github.com/srwareham/dffmpeg.git
    cd dffmpeg
    # Build the default alpine linux image with the tag "alpine-ffmpeg"
    ./build.sh
    # Copy dffmpeg.sh to a location that *should* be in the default $PATH setup for most systems 
    # (Also removes the file extension following unix executable naming conventions)
    cp dffmpeg.sh /usr/local/bin/dffmpeg

Note: the :code:`./build.sh` step may take awhile depending on the underlying image you choose. Images requiring large downloads and compilations may take a significant amount of time.

TL;DR
+++++

.. code-block:: bash

    git clone https://github.com/srwareham/dffmpeg.git && cd dffmpeg && ./build.sh && cp dffmpeg.sh /usr/local/bin/dffmpeg

Customized Install Steps
------------------------

.. code-block:: bash

    # Download dffmpeg.sh and the Dockerfile to build the default Arch Linux image implementation
    git clone https://github.com/srwareham/dffmpeg.git
    cd dffmpeg
    # Modify the default image name from "alpine-ffmpeg" to that of your choosing (e.g., "arch-ffmpeg")
    nano build.sh
    <replace "image_name=alpine-ffmpeg" with "image_name=arch-ffmpeg" for example>
    # Build the desired image with the tag specified above
    ./build.sh
    # Copy dffmpeg.sh to a location that *should* be in the default $PATH setup for most systems 
    # (Also removes the file extension following unix executable naming conventions)
    cp dffmpeg.sh /usr/local/bin/dffmpeg

Adding Your Own ffmpeg Image
++++++++++++++++++++++++++++

To specify an :code:`ffmpeg` image of your own design, simply create a new subdirectory within "images." Inside, you will need to create a Dockerfile that has :code:`ffmpeg` configured as its entrypoint and a build.sh that builds the image with a name of your choosing.

Note:

1. The name of your new image *must* be the same as the directory that contains it
2. build.sh will be executed from within the directory that contains it (i.e., build.sh can take the form :code:`docker build -t $image_name .`


Limitations
===========

Commands supported
------------------

:code:`dffmpeg` currently only supports commands that actually process files from the local system. The script parses commands to determine which host directories need to be mounted to the guest container for input/output. As a result, two main types of commands are not supported

1. Simple commands that do not perform any audio/video manipulations (e.g., :code:`ffmpeg -encoders`)
2. Complex commands that use redirection to perform audio/video manipulations (e.g., commands *outside* of the form:  :code:`ffmpeg ___ -i $path_to_file ___ $path_to_output`


I personally have no use for 1, as it is fairly easy to simply enter the relevant :code:`ffmpeg` container via :code:`docker run --rm -it --entrypoint=/bin/sh $image_name` and then manually run any :code:`ffmpeg` containers from within. If interest exists in adding this feature, I would be happy to accept any pull requests or to otherwise implement some trivial edge cases into the existing script

| As with 1, I have no personal use for 2. If anyone would have a use case for this, and some examples using a typical :code:`ffmpeg` binary, I would be happy to look into the feasibility of porting such behavior to :code:`ffmpeg`. From my understanding of docker, it is possible to redirect stdin and stdout, so I would assume such features are possible.

Space/Feature Set Balance
-------------------------

Due to the licensing on many popular feature implementations, any version of :code:`ffmpeg` you install  will (irrespective of the use of docker) will require you to choose between install speed, install size, and feature set. In practice, you can choose :code:`ffmpeg`: 

1. Made quickly with some feature limitations and a relatively small install size; or
2. Made slowly for:
 
 a. Expanded features
 b. Minimum install size.

In my experience, the two provided images should cover ~99% of use cases: 

1. :code:`alpine-ffmpeg` for use case 1; and
2. :code:`arch-ffmpeg` for use case 2.a.

For use case 1, the provided alpine implementation *should* be a more or less optimal approach. 

| For use case 2.a, the provided :code:`arch-ffmpeg` implementation is not optimized for size and doesn't include *every* :code:`ffmpeg` feature. If space is not a concern, it would be relatively straightforward to replace included `ffmpeg-libfdk_aac <https://aur.archlinux.org/packages/ffmpeg-libfdk_aac/>`_ with `ffmpeg-full-git <https://aur.archlinux.org/packages/ffmpeg-full-git/>`_ and have *every* :code:`ffmpeg` feature. This was not originally chosen for the provided implementation because it requires *much* more compilation time, uses significantly more space, and is frequently broken by updates. If anyone would like to commit to maintaining such an implementation, I would be happy to host it here. It would also be fairly trivial to simply delete many unneeded files from the provided :code:`arch-ffmpeg`, I will probably do so eventually.

| For use case 2.a and 2.b together, the clear choice is to statically compile :code:`ffmpeg` with all desired features, delete the compilation precursors, and simply keep the statically compiled binary. Having done this a few times, this process is extremely involved, involves *lots* of compilation time, requires more configuration than one might expect, and generally requires significant maintenance over time (source code structures, hosting providers, and configuration options frequently change). Although labor intensive, this process suits itself rather nicely to a dockerized solution: you can use a docker container to statically compile :code:`ffmpeg`, store the output binary in a docker volume, and then use a new container referencing this volume to execute any :code:`ffmpeg` tasks (and delete the compilation container). If you are interested in a starting point for such a solution, checkout my very similar project `docker-ffmpeg-compiler <https://github.com/srwareham/docker-ffmpeg-compiler>`_.


Dependencies
============

* `Docker <https://www.docker.com/>`_
* `Bash <https://www.gnu.org/software/bash/>`_

Provided Images
===============

Alpine Linux (Default)
----------------------
The default :code:`ffmpeg` container for this repositiory is uses the lightweight `alpine linux <https://alpinelinux.org/>`_ distribution and its `ffmpeg <https://pkgs.alpinelinux.org/package/v3.3/main/x86/ffmpeg>`_ package.

Size
++++

~50MB

Pros
++++

* Only ~50MB
* *Very* quick build time as no compilation is necessary
* *Most* popular codecs are included (see Cons)

Cons
++++

* libfdk_aac not provided (libfdk_aac's license prevents it from being distributed in binary format. For libfdk_aac to be included, libfdk_aac would have to be manually compiled and then ffmpeg would have to be built with :code:`--enable-libfdk-aac` configured

Video Codecs
++++++++++++

* libx264
* libx265
* libvpx
* libvpx-vp9
* libtheora

Audio Codecs
++++++++++++

* aac 
* libopus
* libvorbis
* libmp3lame
* flac
* alac


Arch Linux
----------

The Arch-Linux-based image provided in this repository uses an updated version of the docker image :code:`base/archlinux` to install `ffmpeg-libfdk_aac <https://aur.archlinux.org/packages/ffmpeg-libfdk_aac/>`_ from the Arch User Repository (AUR). To use this image, simply modify the top-level :code:`build.sh` by replacing :code:`image_name=alpine-ffmpeg` with :code:`image_name=arch-ffmpeg` before running :code:`build.sh`.

Size
++++
~1.3 GB

Pros
++++

* Includes support for libfdk_aac and most popular audio/video codecs

Cons
++++

* 1.3 GB (Note that if your system is already using an updated :code:`base/archlinux` image with :code:`yaourt`, the actual space consumption of :code:`ffmpeg` + libraries is ~350MB
* Long build process. The steps this image takes to build are:

 1. Downloads the :code:`base/archlinux` if necessary
 2. Creates an updated :code:`base/archlinux` layer (updates databases/packages)
 3. Creates a layer with `yaourt <https://archlinux.fr/yaourt-en>`_ setup
 4. Creates a layer with `ffmpeg-libfdk_aac <https://aur.archlinux.org/packages/ffmpeg-libfdk_aac/>`_

Video Codecs
++++++++++++

* libx264
* libx265
* libvpx
* libvpx-vp9
* libtheora

Audio Codecs
++++++++++++

* libfdk_aac
* aac 
* libopus
* libvorbis
* libmp3lame
* flac
* alac
