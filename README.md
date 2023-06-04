# How To Use

After cloning the repo, run `./create-syms.sh` to create a directory called `syms` which contains symlinks for every file in this repo which one might like to have on path, then include this directory in your path (something like `export PATH="$HOME/global/syms:$PATH"`).

For **funcs.sh**, simply source the `global/funcs.sh` file to add the bash functions to your current shell session with `. global/funcs.sh` or `source global/funcs.sh`

It is reccommended that you add

```
export PATH="$HOME/global/syms:$PATH"
. "$HOME/global/funcs.sh"
```

to your `.bashrc` or `.zshrc`