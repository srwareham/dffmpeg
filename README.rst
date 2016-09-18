=======
dffmpeg 
=======

dffmpeg is a dockerized version of ffmpeg. With dffmpeg, any system that supports docker can have a fully functioning version of ffmpeg without having to install any dependencies (besides docker).

.. contents:: Table of Contents
   :depth: 2


How Does dffmpeg Work?
======================

dffmpeg consists of two parts:

1. A docker image that has ffmpeg configured as its entrypoint
2. A bash executable to format ffmpeg commands to be run via docker

dffmpeg Docker Image
--------------------

| For dockerizing ffmpeg, ffmpeg is installed inside of a docker image and the image's entrypoint is configured to be the installed ffmpeg binary. 

| As part of this repository, an example implementation using an arch linux docker image and the Arch User Repository ("AUR") package `ffmpeg-libfdk_aac <https://aur.archlinux.org/packages/ffmpeg-libfdk_aac/>`_.
 
dffmpeg Executable
------------------

| dffmpeg provides dffmpeg.sh to be used as a drop-in replacement for ffmpeg. dffmpeg.sh is called in exactly the same manner as ffmpeg, but instead of a local ffmpeg binary (with all of its installed dependencies), dffmpeg executes ffmpeg from within a neatly contained docker container.

|  Any docker container with ffmpeg as its entrypoint can be used by dffmpeg.sh (to do so, simply change the :code:`dffmpeg_image_name` variable within dffmpeg.sh from :code:`arch-ffmpeg` to the name of the desired replacement image.

Installation
============

Installing dffmpeg consists of two main steps:

1. Building a docker image that has ffmpeg as its entrypoint; and
2. Saving dffmpeg.sh to a path accessible by your system's $PATH

Default Install Steps
---------------------
.. code-block:: bash

    # Download dffmpeg.sh and the Dockerfile to build the default arch linux image implementation
    git clone https://github.com/srwareham/dffmpeg.git
    cd dffmpeg
    # Build the default arch linux image with the tag "arch-ffmpeg"
    ./build.sh
    # Move dffmpeg.sh to a location that *should* be in the default $PATH setup for most systems 
    # (Also removes the file extension following unix executable naming conventions)
    mv dffmpeg.sh /usr/local/bin/dffmpeg

Note: the ./build.sh step will take awhile as it creates a new docker image by:

1. Ensuring the base/archlinux is available locally
2. Creating an updated base/archlinux layer 
3. Creating a layer with `yaourt <https://archlinux.fr/yaourt-en>`_ setup
4. Creating a layer with `ffmpeg-libfdk_aac <https://aur.archlinux.org/packages/ffmpeg-libfdk_aac/>`_

TL;DR
~~~~~

.. code-block:: bash

    git clone https://github.com/srwareham/dffmpeg.git && cd dffmpeg && ./build.sh && mv dffmpeg.sh /usr/local/bin/dffmpeg

Usage
=====

Once installed via the steps above, dffmpeg is called exactly the same as ffmpeg:

.. code-block:: bash

    $ dffmpeg -i input.mp4 -vcodec libx264 output.mp4
    $ dffmpeg -i /path/to/input.mkv -vcodec libx264 -acodec libfdk_aac /path/to/output.mkv

Note: dffmpeg currently requires any input files to be present as a file on the host system (i.e., ffmpeg commands outside of the form of :code:`ffmpeg ___ -i $path_to_file ___ $path_to_output` are untested and likely will not work. If demand exists for inputs via stdin etc. I can look into the feasibility of accomplishing this with docker (it might not be possible at this time).


Features
========

- No dependencies installed on the host system

- Drop-in replacement for a locally-installed ffmpeg binary

- Limited to no overhead executing ffmpeg within a docker container

- Portability across all hosts: if docker can run on your system, you can have full ffmpeg support

- No compiling/gathering dependencies: as a turnkey solution, all you have to do is run the initial setup script to have access to ffmpeg



Default Arch Linux Implementation
---------------------------------

The default Dockerfile provided in this repository uses an updated version of the docker image base/archlinux to install `ffmpeg-libfdk_aac <https://aur.archlinux.org/packages/ffmpeg-libfdk_aac/>`_ from the Arch User Repository (AUR). Encoders from this implementation include:

Video
~~~~~

* libx264
* libx265
* libvpx
* libvpx-vp9
* libtheora

Audio
~~~~~

* libfdk_aac
* aac 
* libopus
* libvorbis
* libmp3lame
* flac
* alac

Cons
~~~~

| The example implementation has not been optimized for space efficiency. On my arch host, the image currently occupies ~ 1.3GB. It could be shrunk with some work, but the main benefits are not space-oriented.


If you are looking for a maximally compact, dockerized solution, you will want to use docker container to statically compile ffmpeg, store the output binary in a docker volume, and then use a new container referencing this volume to execute any ffmpeg tasks (and delete the compilation container). This is a very involved process that involves many dependency headaches and *a lot* of compiling time. If you are interested in a starting point for such a solution, checkout my very similar project `docker-ffmpeg-compiler <https://github.com/srwareham/docker-ffmpeg-compiler>`_.


Dependencies
============

* `Docker <https://www.docker.com/>`_
* `Bash <https://www.gnu.org/software/bash/>`_
