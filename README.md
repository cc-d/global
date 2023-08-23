# Global Repo

This is a repo I have cloned on almost every unix-based environnment that I've worked in.

I've overriden the `cd` command with custom functionality which displays a colored and sorted list of file names in whichever dir was the target of `cd`.

Originally I had a sh function that did this, then a python script, then finally I wrote the utility using cpp for optimization reasons. Going from python -> c++ was about a 90% performance improvement.

## Important Files


### GLOBALSHELL
`init-globalshell.sh` initalizes what I call 'globalshell' which is basically a set of utilities etc that I want across all evironments I work in. Any shell scripts should be posix compliant and work on both linux as well as macos.

`globalshell/aliases.sh` As name implies, contains the aliases loaded into the shell.

`globalshell/funcs.sh` Contains most of the (posix compliant... hopefully!) custom functions/utilities that are loaded into the shell.

### Colorprint

This was created to work around issues with in-terminal color lines being broken at incorrect widths. It had to be maximally or otherwise it would be annoying to use.