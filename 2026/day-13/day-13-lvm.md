# Day 13 - Understanding Linux Storage and LVM

Today was about understanding how storage works in Linux and then using LVM to manage it more flexibly.

Before getting into LVM, I first needed to understand a few things that kept coming up: **disks, volumes, block storage, attaching, formatting, and mounting**.

---

## Storage, Disks and Volumes

These terms are closely related, but the simple idea is this:

A **disk or volume provides storage**, and Linux sees storage devices as **block devices**.

In AWS, EBS stands for **Elastic Block Store**. An EBS volume is block storage that can be attached to an EC2 instance.

Once attached, Linux sees it as a block device.

```text
EBS Volume
    ↓
Attached to EC2
    ↓
Visible to Linux as a block device
```

To check the available block devices, I used:

```bash
lsblk
```

To check disk space and mounted filesystems:

```bash
df -h
```

<!-- Add screenshot: initial lsblk and df -h output -->

---

## Attaching vs Mounting

This was one of the main things I wanted to understand clearly.

**Attaching** a volume means connecting it to the EC2 instance.

At this point, Linux can see the disk, but that does not automatically mean it is ready to store files.

**Mounting** means making the filesystem on that storage accessible through a directory.

```text
Attach
= Connect the volume to the instance

Mount
= Make its filesystem accessible at a location in Linux
```

For example:

```text
/dev/nvme3n1
      ↓
Create filesystem
      ↓
Mount it
      ↓
/mnt/practice_disk_mount
```

Once mounted, the storage can be accessed through that directory.

---

## A Disk Can Be Used Directly

Not every disk needs LVM.

A physical volume can also be used directly by:

1. Creating a filesystem
2. Creating a mount point
3. Mounting it

For example:

```bash
mkfs -t ext4 /dev/nvme3n1
```

Then:

```bash
mount /dev/nvme3n1 /mnt/practice_disk_mount
```

The flow is simply:

```text
Disk
 ↓
Filesystem
 ↓
Mount
 ↓
Use the storage
```

<!-- Add screenshot: /dev/nvme3n1 formatted and mounted -->

The third disk in my setup was used this way, outside of LVM.

---

# Where LVM Comes In

LVM stands for **Logical Volume Manager**.

Instead of working directly with individual disks, LVM adds layers that make storage more flexible.

The basic flow is:

```text
Physical Disk
      ↓
Physical Volume (PV)
      ↓
Volume Group (VG)
      ↓
Logical Volume (LV)
      ↓
Filesystem
      ↓
Mount Point
```

The main benefit is that multiple disks can be combined into a larger storage pool.

---

## Physical Volumes (PV)

I had two disks available:

```text
/dev/nvme1n1 → 7 GiB
/dev/nvme2n1 → 10 GiB
```

Before LVM could use them, I created Physical Volumes:

```bash
pvcreate /dev/nvme1n1 /dev/nvme2n1
```

A Physical Volume is simply a disk prepared for LVM.

I checked them using:

```bash
pvs
```

<!-- Add screenshot: pvcreate and pvs output -->

---

## Volume Group (VG)

The two Physical Volumes were then combined into a Volume Group:

```bash
vgcreate practice_vg /dev/nvme1n1 /dev/nvme2n1
```

You can think of a Volume Group as a **pool of storage**.

```text
7 GiB disk  ──┐
              ├── practice_vg
10 GiB disk ──┘
```

Instead of managing the two disks separately, LVM now manages their available storage together.

I verified the Volume Group using:

```bash
vgs
```

<!-- Add screenshot: vgcreate and vgs output -->

---

## Logical Volume (LV)

From the Volume Group, I created a 10 GiB Logical Volume:

```bash
lvcreate -L 10G -n practice_lv practice_vg
```

The structure now looked like this:

```text
Physical Volumes
       ↓
   practice_vg
       ↓
   practice_lv
```

A Logical Volume is the amount of storage we actually allocate from the Volume Group.

In my case:

```text
Combined storage pool
        ↓
Allocate 10 GiB
        ↓
practice_lv
```

I checked the Logical Volume using:

```bash
lvs
```

<!-- Add screenshot: lvcreate and lvs output -->

---

## Creating a Filesystem

At this point, the Logical Volume existed, but it still needed a filesystem.

I formatted it with `ext4`:

```bash
mkfs.ext4 /dev/practice_vg/practice_lv
```

The filesystem is what allows Linux to organise and store files on the storage.

<!-- Add screenshot: mkfs.ext4 output -->

---

## Mounting the Logical Volume

Next, I created a mount point:

```bash
mkdir -p /mnt/practice_mount
```

Then mounted the Logical Volume:

```bash
mount /dev/practice_vg/practice_lv /mnt/practice_mount
```

I verified it using:

```bash
df -h
```

<!-- Add screenshot: mount and df -h output -->

The storage was now accessible through:

```text
/mnt/practice_mount
```

The complete flow was now:

```text
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
                  ext4
                    ↓
          /mnt/practice_mount
```

---

## Extending the Logical Volume

This is where LVM becomes particularly useful.

I initially created a 10 GiB Logical Volume.

Later, I extended it by 200 MiB:

```bash
lvextend -L +200M /dev/practice_vg/practice_lv
```

Then I extended it again by 2 GiB:

```bash
lvextend -L +2G /dev/practice_vg/practice_lv
```

The Logical Volume eventually grew to around 12.2 GiB.

<!-- Add screenshot: lvextend output -->

However, extending the Logical Volume alone is not enough.

The filesystem also needs to be resized so it can use the additional space.

Since I used `ext4`, I ran:

```bash
resize2fs /dev/practice_vg/practice_lv
```

<!-- Add screenshot: resize2fs and final lsblk output -->

The process was:

```text
lvextend
    ↓
Logical Volume gets bigger
    ↓
resize2fs
    ↓
Filesystem can use the new space
```

---

## A Quick Note on Device Names

You may see different disk names depending on the system.

For example:

```text
/dev/xvda
/dev/xvdf
```

or:

```text
/dev/nvme0n1
/dev/nvme1n1
```

On my EC2 instance, the EBS volumes appeared as `nvme` devices.

The device name may differ, but the storage concepts remain the same.

---

## One More Thing: Snapshots

In AWS, a **snapshot** is a point-in-time backup of an EBS volume.

```text
EBS Volume
     ↓
Snapshot
     ↓
Backup of the volume
```

---

# What I Learned

- **Attaching and mounting are different.** Attaching connects a volume to an instance, while mounting makes its filesystem accessible through a directory.
- **A disk can be used directly or through LVM.**
- **LVM uses three main layers:** Physical Volume → Volume Group → Logical Volume.
- **A Volume Group acts as a storage pool**, from which Logical Volumes can be created.
- **After creating or extending storage, the filesystem matters too.**
- **Extending an LV and resizing the filesystem are separate steps.**

---

## Quick Revision

```text
Normal disk:

Disk
 ↓
Filesystem
 ↓
Mount
 ↓
Use
```

```text
With LVM:

Disk
 ↓
pvcreate
 ↓
Physical Volume
 ↓
vgcreate
 ↓
Volume Group
 ↓
lvcreate
 ↓
Logical Volume
 ↓
mkfs.ext4
 ↓
Filesystem
 ↓
mount
 ↓
Use
```

```text
To add more space:

lvextend
    ↓
Logical Volume grows
    ↓
resize2fs
    ↓
Filesystem grows
```

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
