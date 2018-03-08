FROM archlinux/base

# Create an up-to-date full arch env
RUN pacman --noconfirm -Syy && pacman --noconfirm -S archlinux-keyring && pacman --noconfirm -S pacman && pacman-db-upgrade && pacman --noconfirm -Syu && pacman --noconfirm -S base-devel

# Set environment to compile multi-threaded
RUN export cores=$(nproc); sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j${cores}\"/g" /etc/makepkg.conf; unset cores

# Prepare image for yaourt
# installs git, allows sudo to be run within Docker (thanks to https://bit-traveler.blogspot.com/2015/11/sudo-error-within-docker-container-arch.html)
# creates yaourt user in wheel group (to have sudo access)
RUN pacman -S --noconfirm sudo git && \
sed -i -e 's/*               -       nice            0/#*               -       nice            0/g' /etc/security/limits.conf && \
useradd -m -G wheel yaourt && echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Use yaourt user as mkpkg does not allow creation as root
USER yaourt

# install yaourt
RUN cd /tmp && git clone https://aur.archlinux.org/package-query.git && cd package-query && makepkg -si --noconfirm && \
cd /tmp && git clone https://aur.archlinux.org/yaourt.git && cd yaourt && makepkg -si --noconfirm

# Use yaourt to install ffmpeg-libfdk_aac
# Add perl_core to path so that pod2man can be found
# Skip checks because upstream is always ahead of the repo
#RUN yaourt --noconfirm -S libfdk-aac libvdpau libvorbis &&
RUN PATH=$PATH:/usr/bin/core_perl/ && yaourt --m-arg "--skippgpcheck" --noconfirm -S ffmpeg-libfdk_aac

ENTRYPOINT ["/usr/sbin/ffmpeg"]
