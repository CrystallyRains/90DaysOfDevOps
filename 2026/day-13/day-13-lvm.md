Day 13 - Linux Volume Management (LVM)
Objective

The goal of today's challenge was to understand Linux Logical Volume Management (LVM) and practice managing storage flexibly.

For this hands-on, I worked with multiple attached EBS volumes to create:

Physical Volumes (PV)
A Volume Group (VG)
A Logical Volume (LV)
An ext4 filesystem
A mounted filesystem
An extended logical volume
1. Checking Available Storage

I first checked the available disks using:

lsblk

The system showed the following additional disks:

/dev/nvme1n1 - 7 GiB
/dev/nvme2n1 - 10 GiB
/dev/nvme3n1 - 5 GiB

The root filesystem was located on /dev/nvme0n1.

<!-- Screenshot: Initial lsblk output showing all available disks -->
2. Creating Physical Volumes

I initialized two disks as LVM Physical Volumes.

pvcreate /dev/nvme1n1 /dev/nvme2n1

Both disks were successfully initialized as Physical Volumes.

I verified them using:

pvs
<!-- Screenshot: pvcreate command and pvs output -->
3. Creating a Volume Group

Next, I created a Volume Group named practice_vg using the two Physical Volumes.

vgcreate practice_vg /dev/nvme1n1 /dev/nvme2n1

I verified the Volume Group:

vgs

The Volume Group had a total size of approximately 16.99 GiB.

<!-- Screenshot: vgcreate command and vgs output -->
4. Creating a Logical Volume

I created a 10 GiB Logical Volume named practice_lv.

lvcreate -L 10G -n practice_lv practice_vg

I verified the Logical Volume using:

lvs

The Logical Volume was created at:

/dev/practice_vg/practice_lv
<!-- Screenshot: lvcreate command and lvs output -->
5. Checking Detailed LVM Information

I used the following commands to view detailed information about the LVM configuration:

pvdisplay
vgdisplay
lvdisplay

These commands helped me understand the relationship between the Physical Volumes, Volume Group, and Logical Volume.

Physical Volumes
        ↓
Volume Group (practice_vg)
        ↓
Logical Volume (practice_lv)
<!-- Screenshot: pvdisplay, vgdisplay, and lvdisplay output -->
6. Creating a Filesystem

I formatted the Logical Volume with the ext4 filesystem.

mkfs.ext4 /dev/practice_vg/practice_lv
<!-- Screenshot: mkfs.ext4 output -->
7. Mounting the Logical Volume

I created a mount directory:

mkdir -p /mnt/practice_mount

Then I mounted the Logical Volume:

mount /dev/practice_vg/practice_lv /mnt/practice_mount/

I verified the mounted filesystem:

df -h /mnt/practice_mount/

The Logical Volume was successfully mounted at:

/mnt/practice_mount
<!-- Screenshot: mount command and df -h output -->
8. Verifying the LVM Setup

I used:

lsblk

The output showed the Logical Volume and its mount point.

<!-- Screenshot: lsblk showing practice_vg-practice_lv mounted at /mnt/practice_mount -->
9. Extending the Logical Volume

I first extended the Logical Volume by 200 MiB:

lvextend -L +200M /dev/practice_vg/practice_lv

Then I extended it again by 2 GiB:

lvextend -L +2G /dev/practice_vg/practice_lv

The Logical Volume increased from:

10 GiB
→ approximately 10.2 GiB
→ approximately 12.2 GiB
<!-- Screenshot: lvextend output showing both extensions -->
10. Resizing the Filesystem

After extending the Logical Volume, I resized the ext4 filesystem:

resize2fs /dev/practice_vg/practice_lv

The filesystem was resized while it was still mounted.

I then verified the final storage layout using:

lsblk

The Logical Volume showed a final size of approximately 12.2 GiB.

<!-- Screenshot: resize2fs output and final lsblk verification -->
11. Additional Disk Mounting Practice

I also practiced formatting and mounting the third disk separately.

The disk:

/dev/nvme3n1

was formatted with the ext4 filesystem and mounted at:

/mnt/practice_disk_mount

This disk was mounted directly and was not added to the practice_vg Volume Group.

<!-- Screenshot: /dev/nvme3n1 formatted and mounted separately -->
What I Learned
LVM provides a flexible way to manage storage. Multiple Physical Volumes can be combined into a single Volume Group.
Logical Volumes can be extended when additional storage is needed. I increased my Logical Volume from 10 GiB to approximately 12.2 GiB.
Extending a Logical Volume and resizing the filesystem are separate steps. After using lvextend, I used resize2fs so the ext4 filesystem could use the newly allocated space.
LVM Structure Used
/dev/nvme1n1 ─┐
              ├── Physical Volumes
/dev/nvme2n1 ─┘
                    ↓
             Volume Group
              practice_vg
                    ↓
             Logical Volume
              practice_lv
                    ↓
             ext4 filesystem
                    ↓
          /mnt/practice_mount
