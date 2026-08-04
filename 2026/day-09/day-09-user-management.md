# Task 4 – Shared Directory (Explained Simply)

## Goal

Suppose two developers are working on the same project.

- Tokyo creates files.
- Berlin also needs to edit those files.

So we need a folder that both of them can use.

---

# Step 1 – Create the Folder

```bash
sudo mkdir /opt/dev-project
```

### What does this do?

Creates a new directory called:

```
/opt/dev-project
```

Right now, only **root** owns this folder.

---

# Step 2 – Change the Folder's Group

```bash
sudo chgrp developers /opt/dev-project
```

## What is `chgrp`?

`chgrp` means:

> **CHange GRouP**

Every file and folder in Linux has:

- an owner
- a group

Think of it like this:

```
Owner : Tokyo
Group : Developers
```

By default our folder looked something like:

```
Owner : root
Group : root
```

After running:

```bash
sudo chgrp developers /opt/dev-project
```

it becomes

```
Owner : root
Group : developers
```

Now everyone inside the **developers** group can use this folder (depending on permissions).

---

# Step 3 – Give Folder Permissions

```bash
sudo chmod 775 /opt/dev-project
```

## What is `chmod`?

`chmod` means

> **CHange MODe**

Mode simply means **permissions**.

---

## Understanding 775

```
775
│││
││└── Others
│└── Group
└── Owner
```

Each number is made from:

| Number | Permission |
|---------|------------|
|4|Read|
|2|Write|
|1|Execute|

So

```
7 = 4+2+1
```

means

```
Read
Write
Execute
```

while

```
5 = 4+1
```

means

```
Read
Execute
```

So

```
775
```

means

| Who | Permission |
|------|------------|
|Owner|Read Write Execute|
|Group|Read Write Execute|
|Others|Read Execute|

---

At this point it looks like everything should work.

Tokyo creates a file.

```bash
sudo -u tokyo touch /opt/dev-project/tokyo-notes.txt
```

Berlin is also in the developers group.

So...

Should Berlin be able to edit Tokyo's file?

Most people would say **Yes**.

Linux says...

**No.**

---

# Why Didn't It Work?

Because folder permissions and file permissions are different things.

The folder only decides:

- Can you enter?
- Can you create files?
- Can you delete files?

It **does NOT decide who can edit a file.**

Every file has its own permissions.

Tokyo's file looked like:

```
Owner : tokyo
Group : tokyo
Permission : 644
```

Notice the group.

The file belongs to **tokyo**, not **developers**.

That's why Berlin couldn't edit it.

---

# Problem 1

New files inherit the creator's group.

Instead of

```
developers
```

they become

```
tokyo
```

We need to change that.

---

# Solution 1 – setgid

```bash
sudo chmod 2775 /opt/dev-project
```

Notice the extra **2**.

```
2775
^
```

That **2** enables something called **setgid**.

---

## What does setgid do?

Normally

Tokyo creates a file.

```
shared.txt

Owner : tokyo
Group : tokyo
```

After enabling setgid

Tokyo creates a file.

Now Linux says

> "This file is inside a developers folder."

So instead of giving it Tokyo's group,

it automatically gives it

```
Owner : tokyo
Group : developers
```

Every new file now belongs to the folder's group.

That makes collaboration much easier.

---

## Easy Way to Remember

Without setgid

```
Creator decides the group.
```

With setgid

```
Folder decides the group.
```

---

# Problem 2

Even though the file now belongs to

```
developers
```

Berlin still couldn't edit it.

Why?

Because the file permissions were

```
644
```

which means

|Owner|Read Write|
|Group|Read Only|
|Others|Read Only|

The group still cannot write.

---

# Why Did Linux Create 644?

Linux automatically creates files using something called

```
umask
```

---

# What is umask?

Think of umask as

> Linux's default permission filter.

Whenever you create a new file,

Linux first thinks

```
I'll make it 666.
```

Meaning

```
Read + Write
for everyone.
```

Then it applies the umask.

Ubuntu's default umask is

```
022
```

That removes write permission from

- Group
- Others

So

```
666
```

becomes

```
644
```

That's why almost every new file is

```
644
```

---

# Changing the umask

```bash
umask 002
```

Now Linux removes write permission only from Others.

So

```
666
```

becomes

```
664
```

Now the group can also write.

Perfect for shared projects.

---

## Easy Way to Remember

```
umask
```

doesn't ADD permissions.

It REMOVES permissions.

---

# What About Old Files?

setgid only affects files created **after** enabling it.

Old files stay unchanged.

So we must fix them manually.

---

## Change the Group

```bash
sudo chgrp -R developers /opt/dev-project
```

The `-R` means

> Recursive

Instead of changing only the folder,

Linux changes

- the folder
- every file
- every subfolder

Now everything belongs to the developers group.

---

## Give Group Write Permission

```bash
sudo chmod -R g+w /opt/dev-project
```

Let's break it down.

```
g
```

means

```
Group
```

```
+
```

means

```
Add
```

```
w
```

means

```
Write permission
```

So

```
g+w
```

means

> Give write permission to the group.

Again,

```
-R
```

means

Apply this to everything inside the folder.

---

Now Berlin can finally edit Tokyo's files.

Mission accomplished.

---

# Final Picture

Without any changes

```
Folder
 └── shared.txt

Owner : tokyo
Group : tokyo
Permission : 644

Berlin ❌ Cannot edit
```

After

- setgid
- umask 002
- chgrp
- chmod

we get

```
Folder
 └── shared.txt

Owner : tokyo
Group : developers
Permission : 664

Berlin Can edit
```

---

# Quick Revision

| Command | Simple Meaning |
|----------|----------------|
|`mkdir`|Create a folder|
|`chgrp developers folder`|Change the folder's group|
|`chmod 775 folder`|Give folder permissions|
|`chmod 2775 folder`|Enable setgid so new files inherit the folder's group|
|`umask 002`|Allow the group to have write permission on new files|
|`chgrp -R developers folder`|Change group of everything inside|
|`chmod -R g+w folder`|Give write permission to the group for everything inside|
