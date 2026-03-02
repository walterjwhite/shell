# configuration

## Intent
'configuration' is intended to assist with backing up and restoring user configuration (.dotfiles).
Once a configuration is setup as desired, one can back it up easily and then restore it safely.

## Files not backed up
1. ~/Desktop
2. ~/Downloads
3. other 'dotfiles' not listed
4. installed apps
5. media and other files

## Gotchas
1. thunderbird profile restoration depends on the source and target systems having a matching major thunderbird version.  If the major versions do NOT match, profile restoration may not work and may require manual configuration to properly restore:
    a. run thunderbird, exit thunderbird if configuration appears to have been ignored
    b. remove newly created profile directory
    c. update installs.ini and profiles.ini to point to existing, configured profile
    d. run thunderbird, configuration should be restored
    e. @see: move-thunderbird-profile cmd which performs this function

## New machine provisioning
1. install 'install' app
2. install other apps as desired, app-install configuration git ...
3. create baseline configuration from another git repository
   conf restore-from https://github.com/walterjwhite/configuration.git
