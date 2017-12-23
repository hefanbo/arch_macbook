# Install Arch Linux on MacBook
Fanbo He <<hefanbo@gmail.com>> ([CC BY 4.0](https://creativecommons.org/licenses/by/4.0/))

2017/12/23

Insall Arch Linux along with Mac OS on MacBook Pro.

## Info
- Hardware: MacBook Pro (Retina, 13-inch, Early 2015)
- Software: Arch Linux (201711)

## References
- [Arch Linux Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide)
- [Arch Linux Mac Guide](https://wiki.archlinux.org/index.php/mac)

## Make Free Disk Space
- In MacOS, run Disk Utility.app (located in /Applications/Utilities)
- Select the drive to be partitioned in the left-hand column (not the partitions!). Click on the Partition button.
- Add a new partition by pressing the + button and choose how much space you want to leave for MacOS (in this article, 32GB), and how much for the new partition. Keep in mind the new partition will be formatted in Arch Linux, so you can choose any partition type you want.

## Prepare Installation Media
- Download Arch Linux image from https://www.archlinux.org/download/
- Make a bootable USB stick with [LiLi USB Creator](https://www.linuxliveusb.com/)

## Install

### Boot from installation media
- Plug the USB stick in
- Press power key. Hold `ALT` key until boot menu shows. Select `EFI boot`.

### Connect to WiFi (WPA2, Hidden SSID)
Use the following command to find the network interface name, e.g., `wlp3s0`
```
# iw dev
```

Bring up the interface
```
# ip link set wlp3s0 up
```

Configure SSID and password:
```
# wpa_passphrase MYSSID > wpa.conf
```
Type password and press enter. Edit `wpa.conf`, add following lines
```
ctrl_interface=/run/wpa_supplicant
update_config=1
network={
    ...
    scan_ssid=1
    ...
}
```
Connect and obtain IP
```
# wpa_supplicant -B -i wlp3s0 -c wpa.conf
# dhcpcd wlp3s0
```

In case something goes wrong, use `wpa_cli` to find some clues
```
# wpa_cli -i wlp3s0
```

### Follow the Arch installation guide
```
# ls /sys/firmware/efi/efivars
# timedatectl set-ntp true
```
Check partition info to get device names, e.g., `/dev/sda*`
```
# fdisk -l
```

Modify partitions with `cgdisk`:
```
# cgdisk /dev/sda
```
Delete the partition which is reserved for disk space. Add partition, type `+128M` for start, and `-128M` for end. Write and exit.

Format partition and mount, assuming that `/dev/sda1` is the EFI partition, and `/dev/sda3` is the partition for Linux.
```
# mkfs.ext4 /dev/sda3
# mount /dev/sda3 /mnt
# mkdir /mnt/boot
# mount /dev/sda1 /mnt/boot
```

Find PARTUUID for `/dev/sda3`, e.g., `XXXX-YYYY-ZZZZ`
```
# ls -l /dev/disk/by-partuuid
```

In `/etc/pacman.d/mirrorlist`, delete unwanted mirror entries. Install base:
```
# pacstrap /mnt base
# genfstab -U /mnt >> /mnt/etc/fstab
# arch-chroot /mnt
# ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# hwclock --systohc
```
Uncomment `en_US.UTF-8 UTF-8` in `/etc/locale.gen`
```
# locale-gen
```
Edit `/etc/locale.conf`, add
```
LANG=en_US.UTF-8
```

Add hostname to `/etc/hostname`

Add entry to `/etc/hosts`
```
127.0.1.1	myhostname.localdomain	myhostname
```

Change root password
```
# passwd
```

Install Intel micro code
```
# pacman -S intel-ucode
```

Install and configure `systemd-boot`
```
# bootctl --path=/boot install
```

Edit `/boot/loader/entries/arch.conf`
```
title Arch Linux
linux  /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=PARTUUID=XXXX-YYYY-ZZZZ rw
```

Edit `/boot/loader/loader.conf`
```
default arch
```

## Post-Installation
Create new user
```
# useradd -m -G wheel -s /bin/bash your_user_name
# passwd your_user_name
```

Install some basic software
```
# pacman -S sudo vim wpa_supplicant
```
Edit `/etc/environment`, add
```
EDITOR=vim
```

Add wheel group to sudoers
```
# visudo
```
Uncomment the line
```
%wheel ALL=(ALL) ALL
```

To enable auto-completion for `sudo`, add this line to `.bashrc` in the home directory
```
if [ "$PS1" ]; then
    complete -cf sudo
fi
```

Press `Ctrl-D` to exit chroot, unmount `/mnt/boot` and `/mnt`, reboot.

## Boot
- Press power key, and system will boot to Arch Linux by default.
- Press power key, hold `ALT` until boot menu shows, and select `Macintosh HD` to boot to MacOS

## More Post-Installation
Log in as normal user, and connect to WiFi.

### Number of TTYs
Edit `/etc/systemd/logind.conf`, set `NAutoVTs` and `ReserveVT` values.

### AUR helper
```
$ sudo pacman -S --needed base-devel
$ echo keyring /etc/pacman.d/gnupg/pubring.gpg >> ~/.gnupg/gpg.conf
$ mkdir -p ~/software/aur
$ cd ~/software/aur
$ curl -O -J https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz
$ tar xzf cower.tar.gz
$ cd cower
$ makepkg -si
$ cd ..
$ cower -d pacaur
$ cd pacaur
$ vim PKGBUILD
```
Remove lines related to `zsh` because we don't use it, and run
```
$ makepkg -si
```

### LXQt
```
$ sudo pacman -S x86-video-intel xorg-server lxqt sddm
$ sudo pacman -S xorg-xrandr
$ sudo pacman -S libpulse libstatgrab libsysstat lm_sensors
$ sudo systemctl enable sddm
```
`/usr/bin/xdg-open` expects the file manager to be `pcmanfm` while it is `pcmanfm-qt` actually in LXQt. To fix this, either edit `xdg-open` or make a soft link to `pcmanfm-qt`.

### Screen scale for HiDPI
#### Method 1
Create `/etc/X11/xorg.conf.d/90-monitor.conf`, add
```
Section "Monitor"
    Identifier   "<default monitor>"
    DisplaySize  286 179    # In millimeters
EndSection
```
#### Method 2
Edit `/etc/environment`, add
```
#QT_AUTSCREEN_SCALE_FACTOR=1
#QT_SCREEN_SCALE_FACTOR=2
QT_SCALE_FACTOR=2
GDK_DPI_SCALE=2
```

### Console font size for Hi-DPI display
Edit `/etc/vconsole.conf`, add
```
FONT=latarcyrheb-sun32
```

### Fonts
```
$ sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-cjk
```

### Icons and cursors
```
$ sudo pacman -S papirus-icon-theme xcursor-flatbed
```
Go to `Start -> Preferences -> LXQt settings -> Appearance`, and select themes for current user. To set cursor size, open `.config/lxqt/session.conf`, add `cursor_size=48` to `Mouse` section.

To apply the cursor theme globally, edit `/usr/share/icons/default/index.theme`, set
```
[Icon Theme]
Inherits=FlagbedCursors-Black
```

### LXQt menu
- Right click the application menu, select `Configure`, and you can choose the menu file.
- You can copy the menu file from the default `Menu file` location to `.config/menu`, and use it as an example.

### SDDM theme
Create `/etc/sddm.conf` with the following contents
```
[Theme]
Current=elarun
```
The theme is defined in `/usr/share/sddm/themes/elarun/Main.qml`

### Touchpad
Create `/etc/X11/xorg.conf.d/30-touchpad.conf`
```
Section "InputClass"
  Identifier "TouchPad"
  MatchDriver "libinput"
  MatchProduct "bcm5974"
  Option "AccelSpeed" "1"
  Option "Tapping" "on"
EndSection
```

### Network manager
```
$ pacaur -S cmst
```
Go to `Start -> Preferences -> Session Settings`, and add `/usr/bin/cmst -m` to autostart.

### Brightness adjusting keys
Create `/usr/local/bin/scr_light` with the following contents
```
sysfs="/sys/class/backlight/intel_backlight"
steps=347

max=`cat ${sysfs}/max_brightness`
level=`cat ${sysfs}/brightness`
step=`expr $max / $steps`
min=20

usage()
{
script=${0##*/}
echo
echo "Invalid usage of ${script}!"
echo "  $1"
echo "----------------"
echo "$script up     : increases brightness"
echo "$script down   : decreases brightness"
echo "$script set #  : sets brightness to # (integer)"
echo "----------------"
echo

exit 1
}

set_brightness()
{
level=$1
if [ $level -lt $min ] ; then
 level=$min
elif [ $level -gt $max ] ; then
 level=$max
fi
echo $level > $sysfs/brightness 
}

case "$1" in
  up)
    let "level+=$step"
    set_brightness $level 
    ;;
  down)
    let "level-=$step"
    set_brightness $level 
    ;;
  set)
    if [[ ! $2 =~ ^[[:digit:]]+$ ]]; then
     usage "second argument must be an integer"
    fi

    set_brightness $2
    ;;
  *)
    usage "invalid argument"
esac
```

Add user to `video` group and allow this group to run the script without password
```
$ sudo usermod -aG video $USER
% sudo visudo
```
Add this line
```
%video ALL=(ALL) NOPASSWD: /usr/local/bin/scr_light
```

Open `Shortcut Keys` settings, add `sudo scr_light down` and `sudo scr_light up` commands to appropriate keys.

### Keyboard backlight adjusting keys
Create `/usr/local/bin/kbd_light` identical to `/usr/local/bin/scr_light` with the following exceptions
```
sysfs="/sys/class/leds/smc::kbd_backlight"
steps=5
min=0
```

Add user to `input` group and allow this group to run the script without password

Open `Shortcut Keys` settings, add `sudo scr_light down` and `sudo scr_light up` commands to appropriate keys.

### Sound
There is no sound by default because the default sound output is HDMI. To fix this, there are 3 methods:
#### Method1(recommended): switch the sound card index
Create `/etc/modprobe.d/sound.conf` with the following content
```
options snd-hda-intel index=1,0
```

#### Method2: select correct default sound card
Create `/etc/asound.conf` with the following content
```
defaults.pcm.card 1
```

#### Method3: disable HDMI sound output
Create `/etc/modprobe.d/sound.conf` with the following content
```
options snd-hda-intel enable=0,1
```

### Keyboard
#### Fn key mode
To switch `Fn` key mode, create `/etc/modprobe.d/hid_apple.conf`
```
options hid_apple fnmode=2
```

#### Disable power key
Edit `/etc/systemd/logind.conf`, set
```
HandlePowerKey=Ignore
```

#### Key remapping
Use `lsusb` or `udevadm info` to check internal keyboard device info.

Use `evtest` to check key scan code.
```
$ sudo pacman -S evtest
$ sudo evtest
```

Create `/etc/udev/hwdb.d/10-kbd-modifiers.hwdb`
```
evdev:input:b0003v05ACp0273* # correspongding to keyboard device info
 KEYBOARD_KEY_700e3=leftmeta # leading space is required
 KEYBOARD_KEY_700e3=leftalt
 KEYBOARD_KEY_700e7=delete
 KEYBOARD_KEY_700e6=rightctrl
```

Update database and reboot
```
sudo systemd-hwdb update
```

### Swap
#### Method1: systemdd-swap (no hibernation support)
```
$ sudo pacman -S systemd-swap
```
Set `swapfc_enabled=1` in `/etc/systemd/swap.conf`. And
```
$ sudo systemctl enable systemd-swap
```
#### Method2: swapfile
As `systemd-swap` cannot be used for hibernation, a swap file must be created.
```
$ sudo fallocate -l 5G /swapfile
$ sudo chmod 600 /swapfile
$ sudo mkswap /swapfile
```
Edit `/etc/fstab`, add
```
/swapfile none swap defaults 0 0
```
Create `/etc/sysctl.d/99-sysctl.conf`
```
vm.swappiness=10
```

### Screen saver
```
$ sudo pacman -S xscreensaver 
```
To customize lock dialog of xscreensaver
```
$ sudo pacman -S xorg-xrdb
```
Create `.Xresources` to enlarge font size, hide `New Login` button and the date string
```
xscreensaver.newLoginCommand:
xscreensaver.dateFormat:
xscreensaver.Dialog.headingFont:        -*-noto mono-medium-r-normal-*-*-160-*-*-*-*-*-*
xscreensaver.Dialog.labelFont:          -*-noto mono-medium-r-normal-*-*-240-*-*-*-*-*-*
xscreensaver.Dialog.unameFont:          -*-noto mono-medium-r-normal-*-*-240-*-*-*-*-*-*
xscreensaver.passwd.passwdFont:         -*-noto mono-medium-r-normal-*-*-240-*-*-*-*-*-*
xscreensaver.Dialog.buttonFont:         -*-noto mono-medium-r-normal-*-*-240-*-*-*-*-*-*
```
Create `/etc/X11/xorg.conf.d/10-fontpath.conf`
```
Section "Files"
    FontPath "/usr/share/fonts/noto"
EndSection
```
To test fonts, `xorg-xfontsel` and `xorg-xlsfonts` are recommended.

### Hibernate
```
$ sudo filefrag -v /swapfile
```
Remember the `physical_offset` value in the first row, which is refered as SWAPFILE_OFFSET here after.

Edit `/boot/loader/entries/arch.conf`, add
```
optioins resume=PARTUUID=xxxx-yyyy-zzzz resume-offset=SWAPFILE_OFFSET
```

Edit `/etc/mkinitcpio.conf`, add `resume` behind `udev` in `HOOKS`.
```
$ sudo mkinitcpio -p linux
```

To prevent immediate wake up after suspend/hibernate, create `/etc/udev/rules.d/90-wake.conf`
```
# ARPT
SUBSYSTEM=="pci", KERNEL=="0000:03:00.0", ATTR{power/wakeup}="disabled"
# XHC1
SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", ATTR{power/wakeup}="disabled"
# LID0
SUBSYSTEM=="acpi", KERNEL=="PNP0C0D:00", ATTR{power/wakeup}="disabled"
```
For information, the following commands may be useful
```
$ evtest
$ lspci
$ lsusb
$ cat /proc/acpi/wakeup
$ udevadm info /dev/inputevent2
$ udevadm info -a /dev/inputevent2
```

Reboot.

### Archive
```
$ sudo pacman -S xarchiver
$ sudo pacman -S zip unzip p7zip unrar
```

### Chinese input method
```
$ sudo pacman -S fcitx-im fcitx-configtool fcitx-sunpinyin
```
Edit `/etc/environment`
```
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```

### Directory encryption
```
$ sudo pacaur -S sirikali ecryptfs-simple
```
Create `/etc/modules-load.d/ecryptfs.conf` with the following content
```
ecryptfs
```

### Samba
```
$ sudo pacman -S samba gvfs-smb
```
Create `/etc/samba/smb.conf` based on [this file](https://git.samba.org/samba.git/?p=samba.git;a=blob_plain;f=examples/smb.conf.default;hb=HEAD)

### Disable recently-used.xbel
Edit `.config/gtk-3.0/settings.ini`
```
[Settings]
gtk-recent-files-max-age=0
gtk-recent-files-limit=0
```
Edit `.gtkrc-2.0`
```
gtk-recent-files-max-age=0
```

### Camera (Facetime HD)
```
$ pacaur -S bcwc-pcie-git
```

### KVM
```
$ sudo pacman -S qemu virt-manager
$ sudo pacman -S ebtables dnsmasq
$ sudo systemctl enable libvirtd
$ sudo systemctl enable libvirt-guests
$ sudo usermod -aG libvirt $USER
```

### Other software
```
$ pacman -S goldendict mpv
```

### Trouble shooting
#### Red light coming from headphone jack?
```
$ sudo pacman -S alsa-utiles
$ alsamixer
```
Mute S/PDIF

#### Port 53 is in use?
Disable DNS proxy of connman. Create folder `/etc/systemd/system/connman.service.d`, and add file `disable_dns_proxy.conf`
```
[Service]
ExecStart=
ExecStart=/usr/bin/connmand -n --nodnsproxy
```

## TODO
- Terminal emulator supporting Chinese
- Space between icons is too large when Chinese font is selected
- Color profile from Mac (tried that, but it seems to have no effect, maybe the default color profile is good enough)
- WiFi down after resuming from suspend/hibernate
- Turn off screen when lid close without sleeping
