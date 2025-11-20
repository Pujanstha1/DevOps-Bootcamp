## Day 3 Assignment
### Scenario
You are a DevOps engineer at a XYZ company. The development team works on a shared project located in
`/var/www/project`
. Multiple developers and a deployment user need different levels of access. You must set up proper users, groups, and permissions to ensure security and collaboration.

### Task 1: User and Group Creation
1. **Create the following users:**
- `ram` (developer)
- `hari` (developer)
- `gita` (junior developer – limited access)
- `deploy`(deployment user – used by CI/CD) 
2. **Create two groups:**
- `devteam`
- `deployers`
3. **Add users to groups:**
- `ram` and `hari` → members of `devteam`
`gita` → member of `devteam` but with restricted write access later
- `deploy` → member of `deployers`

## Task 2: Directory and File Setup
1. **Create the project directory:**

    `sudo mkdir -p /var/www/project`

2. **Inside `/var/www/project`, create:**
- `source/` (source code – only devteam can read/write)
- `logs/` (logs – everyone in devteam can append, but not delete others’ files)
- `scripts/` (deployment scripts – only deploy user can execute some scripts)
- `shared/` (shared assets – all devteam can read/write, new files inherit group)

## Task 3: Apply Correct Permissions1.
1. **Set permissions so that:**
- Only members of devteam can enter and modify `/var/www/project/source/`
- The directory should have correct **group ownership** and
**SGID** so new files inherit the group.
- Default umask for `devteam` members should be `002` ***(rwxrwxr-x for dirs, rw-rw-r-- for files)***
2. **For `/var/www/project/logs/`:**
- Everyone in `devteam` can append to logs.
- No one can delete or modify others’ log files → use **sticky bit**
3. For `/var/www/project/scripts/deploy.sh`:
- Only the deploy user should be able to execute it
- Use **SUID** so it runs with owner privileges (assume owner is root or deploy)
4. For `/var/www/project/shared/`:
- All devteam members can read and write
- Use **setgid** so all new files created belong to `devteam` group automatically
## Task 4: umask and Default Permissions
1. Configure the system so that users in `devteam` have a default umask of `002` when they log in. (Hint: Edit `/etc/bashrc` or user-specific profile)

## Task 5: Verification & Testing
1. As user `ram`, create a file in `shared/` and verify:
- Group ownership is `devteam`
- Permissions are `664` (or `775` for directories)
2. As user `gita`, try to delete a file created by `ram` in
`logs/` → should fail due to sticky bit.
3.As user `deploy`, execute the `deploy.sh` script successfully even if not owner.

## Task 6: Documentation (Mandatory)
Write a markdown report including:
- All commands you used
- Screenshot or output of:
    ```
    ls -la /var/www/project/ (and subdirs)
    id ram, hari, gita, deploy
    getfacl (if you used ACLs – bonus)
    ```
- Explanation of why you used SUID/SGID/Sticky bit
- Security implications of your setup
