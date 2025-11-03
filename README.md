# nvidia-340-390-470-slackbuilds

SlackBuilds with the necessary sources to build legacy NVidia drivers (kernel modules, X drivers, and nvidia utilities) versions 340 (for Tesla cards), 390 (for Fermi cards), and 470 (for Kepler cards) for use with XLibre xserver in Slackware.

## Objectives

- To allow a user to install NVidia drivers on systems with recent Linux kernels (tested up to 6.17.6) so that they "just work", with little to no manual intervention;

- To install proprietary modules and libraries in a dedicated directory `/usr/{lib,lib64}/nvidia` so that they do not overwrite open versions from XLibre, Mesa, libglvnd etc;

- To keep `nouveau` kernel and X drivers so that a user is able to choose between them and `nvidia` at boot time, which increases safety (it's almost impossible for both open and proprietary drivers to break simultaneously).

## Source

Build scripts from [slackbuilds.org](https://slackbuilds.org/result/?search=nvidia-legacy&sv=15.0) have been modified, so credits go to Heinz Wiesinger, Edward W. Koenig, and Lenard Spencer who are the authors of the original scripts.

Tags `SBo` are changed to `Nyk` to emphasize that [slackbuilds.org](https://slackbuilds.org/result/?search=nvidia-legacy&sv=15.0) is not responsible for these packages.

The packages for nvidia340 at slackbuilds.org are [abandoned now](https://slackbuilds.org/repository/15.0/system/nvidia-legacy340-driver/), so patches for it are mostly taken from the Andreas Beckmann's [Debian package](https://packages.debian.org/source/sid/nvidia-graphics-drivers-legacy-340xx). He does great job of backporting new features from more recent drivers and adapting the code to changes in Linux kernels.

## Prerequisites

It is assumed that you use the XLibre version for Slackware provided at [https://github.com/ONykyf/X11Libre-SlackBuild](https://github.com/ONykyf/X11Libre-SlackBuild), which contains PRs not yet merged into XLibre master.
They allow to set `IgnoreABI` and `ModulePath`s for specific `Driver`s and `Module`s, and to enable them only if a DRM device driven by `nvidia-drm` is detected.
Then a specially crafted `OutputClass` in `/usr/share/X11/xorg.conf.d/10-nvidia.conf` (which is an enhanced version of a similar file used in XOrg) does the trick.

## How to download

Clone the repository with Git like so:
```
git clone https://github.com/ONykyf/nvidia-340-390-470-slackbuilds.git
cd nvidia-340-390-470-slackbuilds
```
Using this method gives you the opportunity to later simply update the repository by running `git pull origin main` in `nvidia-340-390-470-slackbuilds` directory. Please be advised that the initial download of the Git repository is about 480 Mb.

## How to build and install

Just run `nvidia-legacy${VERSION}-kernel.SlackBuild` and `nvidia-legacy${VERSION}-driver.SlackBuild` in the respective directories for the VERSION you need, and install the obtained packages.

Observe that `*.run` installers from NVidia are one level up in the directory hierarchy to save space. Files for 340 and 390 are included, but the installer for 470 is not because of its size (266455 Kb). The script `get_NVIDIA-Linux-x86_64-470.256.02.run.sh` will download it for you.

The created packages and build logs are put alongside the build scripts (not in `/tmp` or wherever). You can move them to another place to keep the cloned repository intact and not to lose the built packages in case of a repository update.

Note that `nvidia-legacy${VERSION}-driver` is common, but `nvidia-legacy${VERSION}-kernel` should be built and installed separately for all kernels you use (boot each kernel and re-run the build script).

After the installation you will get `/boot/initrd-${KERNEL}.img` initramfs image cleared of `nouveau`, `nvidia`, `nvidia-drm`, `nvidia-uvm` and `nvidia-modeset` kernel modules, which ensures that they will not be loaded at early boot. To simplify its use, an `/etc/lilo.conf.nvidia-${KERNEL}` snippet is generated simultaneously, which looks like this:
```
# Linux bootable partition config begins
image = /boot/vmlinuz-6.12.6
  root = /dev/sda9
  label = Linux-6.12.6+
  read-only  # Partitions should be mounted read-only for checking
  initrd = /boot/initrd-6.12.6.img
  append = " module_blacklist=nouveau nvidia_drm.modeset=1"
# Linux bootable partition config ends
# Linux bootable partition config begins
image = /boot/vmlinuz-6.12.6
  root = /dev/sda9
  label = Linux-6.12.6-
  read-only  # Partitions should be mounted read-only for checking
  initrd = /boot/initrd-6.12.6.img
  append = " module_blacklist=nvidia,nvidia_drm,nvidia_uvm,nvidia_modeset"
# Linux bootable partition config ends
```

Note that `/boot/initrd-${KERNEL}.img` may be overwritten, e.g., when a kernel is reinstalled. If you encounter problems after this, then running `nvidia-prepare-boot` (and `lilo`, if used) with this kernel booted restores the correct initrd image and points the bootloader to its location.

Version 340 of the NVidia driver is not kernel modesetting capable and hence lacks `nvidia_modeset` kernel module, and DRM functionality is implemented in `nvidia` module, i.e., there is no separate `nvidia_drm`.
Therefore `/etc/lilo.conf.nvidia-${KERNEL}` looks simpler:
```
# Linux bootable partition config begins
image = /boot/vmlinuz-6.17.6
  root = /dev/sda3
  label = Linux-6.17.6+
  read-only  # Partitions should be mounted read-only for checking
  initrd = /boot/initrd-6.17.6.img
  append = " module_blacklist=nouveau"
# Linux bootable partition config ends
# Linux bootable partition config begins
image = /boot/vmlinuz-6.17.6
  root = /dev/sda3
  label = Linux-6.17.6-
  read-only  # Partitions should be mounted read-only for checking
  initrd = /boot/initrd-6.17.6.img
  append = " module_blacklist=nvidia,nvidia_uvm"
# Linux bootable partition config ends
```

You can add it (edited if you like) to `/etc/lilo.conf` and re-run `lilo` to choose at boot
which drivers to use. This adds an additional safety margin in case
something goes wrong after an upgrade or an experiment. If you use, say,
GRUB2 instead of LILO, you can take kernel options from here to use
in `grub.cfg`.

*Important note:* you DON'T need to blacklist nouveau in `/etc/modprobe.d/*`. If there is a file that contains a line `blacklist nouveau`, remove it, or unistall `xf86-video-nouveau-blacklist-1.0-noarch-1.txz` package if it has been installed.

## Status and caveats

There is a warning about "tainted kernel" in `dmesg` output.

When Xserver is started, `nvidia-drm` for nvidia 390 complains about failure to grab drm device ownership, which is a long-term issue for NVidia and can be safely ignored.
After that, the nvidia legacy drivers work nice, much better that nouveau (no lags, picture and fonts are clearer).

Note that if you have an integrated card and want it to work alongside with NVidia at a separate seat (as I have Intel),
then the second X instance for it should be run with `-modulepath /usr/lib64/xorg/modules` command-line option, or OutputClass like
```
Section "OutputClass"
    Identifier     "NotNVidia"
    MatchLayout    "Seat1"
    Module         "glx"
    ModulePath     ""
EndSection
```
must be applied to the respective server layout, to prevent loading the GLX library shipped with nvidia instead of the XLibre stock version. This way you obtain different GLX realizations working at different seats.
When a framebuffer for my second (integrated) intel card starts to initialize after nvidia gets initialized, the text console gets black and returns only before X is started. This pause is long (ca 30 seconds) on a box with an RTL8211E Gigabit Ethernet adapter, probably because of entropy starvation when `r8169` is started, and is not related to graphics. 


## NVidia 340 specific notes

The nvidia 340 driver is not GLVND capable and its installer tries to replace some OpenGL-related libraries with its own versions. This makes `nouveau` drivers not work and should be prevented.
Hence the legacy libraries are moved to `/usr/{lib,lib64}/nvidia`, and the package installs a script `/etc/rc.d/rc.nvidia340` that changes soft links to `libGL`, `libEGL`, `libGLESv1_CM`,
`libGLESv2`, and `libOpenCL` between NVidia and system-wide libraries depending on whether `nvidia.ko` kernel module has been loaded at startup. If `ldconfig` without arguments is run, e.g., from an installation script, then the soft links are "corrected", and you temporarily lose OpenGL for `nvidia`. Then reboot a computer or run `/etc/rc.d/rc.nvidia340` as root.

These limitations also make Tesla cards with the nvidia 340 driver an inappropriate choice for multiseat together with non-NVidia cards, but such use can hardly be imagined for this legacy hardware (and I'd suppose that it has never been used this way). For a single seat (with one or more monitors) nvidia 340 works well enough. 

This driver provides OpenGL ES 2.0 only, which is insufficient for GTK4. Use a workaround like
```
GSK_RENDERER=cairo pavucontrol
```
to run GTK4 applications.
