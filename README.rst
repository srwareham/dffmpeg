dffmpeg 
=======

dffmpeg is a dockerized version of ffmpeg. With dffmpeg, any system that supports docker can have a fully functioning version of ffmpeg without having to install any dependencies (besides docker).

Requirements
------------

To use dffmpeg, you need two prerequisites:
 
1. A docker image with ffmpeg set to its entrypoint (arch linux implementation provided in the repository's Dockerfile)

2. The dffmpeg script stored in a location accessible via your shell's $PATH

Example setup steps
+++++++++++++++++++
.. code-block:: bash

    git clone https://github.com/srwareham/dffmpeg.git
    cd dffmpeg
    ./build.sh
    mv dffmpeg.sh /usr/local/bin/dffmpeg

Note: the ./build.sh step will take awhile as it creates a new docker image by:

1. Ensuring the base/archlinux is available locally
2. Creating an updated base/archlinux layer 
3. Creating a layer with `yaourt <https://archlinux.fr/yaourt-en>`_ setup
4. Creating a layer with `ffmpeg-libfdk_aac <https://aur.archlinux.org/packages/ffmpeg-libfdk_aac/>`_

Usage
-----

dffmpeg is called exactly the same way as ffmpeg. 

.. code-block:: bash

    $ dffmpeg -i input.mp4 -vcodec libx264 output.mp4
    $ dffmpeg -i /path/to/input.mkv -vcodec libx264 -acodec libfdk_aac /path/to/output.mkv

Note: dffmpeg currently requires any input files to be present as a file on the host system (i.e., ffmpeg commands outside of the form of :code:`ffmpeg ___ -i $path_to_file ___ $path_to_output` are untested and likely will not work. If demand exists for inputs via stdin etc. I can look into the feasibility of accomplishing this with docker (it might not be possible at this time).


Features
--------

- No dependencies installed to the host system

- Limited to no overhead via executing ffmpeg within a docker container

- Portability across all hosts: if docker can run on your system, you can have full ffmpeg support

- No compiling/gathering dependencies: as a turnkey solution, all you have to do is run the initial setup script to have access to ffmpeg


Cons
----

| The example implementation has not been optimized for space efficiency. On my arch host, the image | | | currently occupies ~ 1.3GB. It could be shrunk with some work, but the main benefit instead is not having conflicting dependencies and not polluting your host namespace.
|

If you are looking for a maximally compact, dockerized solution, you will want to use docker container to statically compile ffmpeg, store the output binary in a docker volume, and then use a new container referencing this volume to execute any ffmpeg tasks (and delete the compilation container). This is a very involved process that involves many dependency headaches and *a lot* of compiling time. If you are interested in a similar, but simplified solution, checkout my very similar project `docker-ffmpeg-compiler <https://github.com/srwareham/docker-ffmpeg-compiler>`_.

Provided Arch Linux Implementation
----------------------------------

The Dockerfile provided in this repository uses an updated version of the docker image base/archlinux to install `ffmpeg-libfdk_aac <https://aur.archlinux.org/packages/ffmpeg-libfdk_aac/>`_ from the Arch User Repository (AUR). Encoders from this implementation include:


Video
++++++

* libx264
* libx265
* libvpx
* libvpx-vp9
* libtheora

Audio
+++++

* libfdk_aac
* aac 
* libopus
* libvorbis
* libmp3lame
* flac
* alac


Dependencies
------------

* `Docker <https://www.docker.com/>`_
