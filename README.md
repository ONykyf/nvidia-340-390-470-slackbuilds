# nvidia390 and nvidia470 slackbuilds for XLibre

Slackbuilds for proprietary nVidia kernel modules, X driver, and utilities, versions 390 (for Fermi cards) and 470 (for Kepler cards)

These are slightly changed versions from slackbuilds.org, so credits go to Heinz Wiesinger, Edward W. Koenig, and Lenard Spencer, who are the authors of the original scripts.

## Changes:

- Adapted to build for XLibre, although should also work for X.Org, if the default `--x-module-path` is changed back from `/usr/lib??/xorg/modules/xlibre-25.0` to `/usr/lib??/xorg/modules/`

- Patches from AUR added to compile and work with recent kernels

- Logs are written to the respective directories and packages built are put there

## Prerequisites:

- You should either have XLibre with `IgnoreABI` and `Module` support in `OutputClass` and `TimerForce()` function reexported (get it at https://github.com/ONykyf/X11Libre-SlackBuild until these changes are merged into a stable version), or (in particular, for X.Org) put `IgnoreABI` option in `ServerFlags` (read `10-nvidia.conf` for details) and change the default nvidia graphic modules path from `/usr/lib??/nvidia/xorg/` to `/usr/lib??/xorg/modules/` (but You will not be able to use proprietary and open drivers simultaneously on a multiseat system)

- parameters `nvidia-drm.modeset=1` and `module_blacklist=nouveau` must be passed to kernel through GRUB, LILO, or whatever you use to boot Linux

- instead of the latter parameter, the `nouveau` kernel driver can be blacklisted by adding `/etc/modprobe.d/BLACKLIST-nouveau.conf` to your system

- `nvidia.ko`, `nvidia-drm.ko`, `nvidia-uvm.ko`, and `nvidia-modeset.ko` should be in initrd to be inserted at early boot

## nvidia470

NVidia installer for 470 is too large (approx. 250 Mb) to store it here, but `get_NVIDIA-Linux-x86_64-470.256.02.run.sh` will download it for You.

You have to run the kernel package build script as
```
KERNEL614=yes ./nvidia-legacy470-kernel.SlackBuild
```
or
```
KERNEL615=yes ./nvidia-legacy470-kernel.SlackBuild
```
if You have linux-6.14 or linux-6.15 kernel respectively, then additional patches will be applied.


## How to avoid risk

You can preserve the possibility to choose between `nvidia` and `nouveau` drivers at boot time. See the following excerpt from `lilo.conf` (for GRUB it requires a little more hacking):
```
# Linux bootable partition config begins
image = /boot/vmlinuz-6.14.0-rc3
  initrd = /boot/initrd-6.14.0-rc3-nvidia.img
  append = " nvidia_drm.modeset=1 module_blacklist=nouveau,nouveaufb"
  root = /dev/sda1
  label = Slackware-15.0+
  read-only  # Partitions should be mounted read-only for checking
# Linux bootable partition config ends
# Linux bootable partition config begins
image = /boot/vmlinuz-6.14.0-rc3
  initrd = /boot/initrd-6.14.0-rc3.img
  append = " module_blacklist=nvidia,nvidia_drm,nvidia_uvm,nvidia_modeset"
  root = /dev/sda1
  label = Slackware-15.0-
  read-only  # Partitions should be mounted read-only for checking
# Linux bootable partition config ends
```
Clearly `initrd-6.14.0-rc3-nvidia.img` contains `nvidia,nvidia_drm,nvidia_uvm,nvidia_modeset` kernel modules and `initrd-6.14.0-rc3.img` does not contain them.


## Status and caveats

There is a warning about "tainted kernel" in `dmesg` output.

When a framebuffer for the second (integrated) intel card starts to initialize after nvidia gets initialized, the text console gets black and returns only before X is started. This pause is long (ca 30 seconds) on a box with an RTL8211E Gigabit Ethernet adapter, probably because of entropy starvation when `r8169` is started, and is not related to graphics. 

When Xserver is started, `nvidia-drm` complains about failure to grab drm device ownership, which is a long-term issue for NVidia:
```
[   22.205067] RPL Segment Routing with IPv6
[   22.205090] In-situ OAM (IOAM) with IPv6
[   35.776277] RTL8211E Gigabit Ethernet r8169-0-300:00: attached PHY driver (mii_bus:phy_addr=r8169-0-300:00, irq=MAC)
[   35.982801] r8169 0000:03:00.0 eth0: Link is Down
[   38.094386] r8169 0000:03:00.0 eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[   38.526457] 8021q: 802.1Q VLAN Support v1.8
[   38.906403] cfg80211: Loading compiled-in X.509 certificates for regulatory database
[   38.906624] Loaded X.509 cert sforshee: 00b28ddf47aef9cea7
[   38.906804] Loaded X.509 cert wens: 61c038651aabdcf94bd0ac7ff06c7248db18c600
[   39.677561] NET: Registered PF_QIPCRTR protocol family
[   70.657424] [drm:drm_new_set_master [drm]] *ERROR* [nvidia-drm] [GPU ID 0x00000100] Failed to grab modeset ownership
[   82.852261] CIFS: Attempting to mount //nigga/family-homes-write
[   83.284368] CIFS: SMB3.11 POSIX Extensions are experimental
```

After X session is started, the nvidia390 and nvidia470 drivers work nice, much better that nouveau (no lags, picture and fonts are clearer). Note that if You have an integrated card and want it to work alongside with nVidia at a separate seat (as i have Intel),
then the second X instance for it should be run with `-modulepath /usr/lib64/xorg/modules` command-line option, or OutputClass like
```
Section "OutputClass"
    Identifier     "NotNVidia"
    MatchLayout    "Seat1"
    Module         "glx"
    ModulePath     ""
EndSection
```
must be applied to the respective server layout, to prevent loading the GLX library shipped with nvidia390 instead of the XOrg stock version. This way You obtain different GLX realizations working at different seats.


