# How To Use

Simply source the `global/myshell.sh` file to add the bash functions to your current shell session with `. global/funcs.sh` or `source global/funcs.sh`

It is reccommended that you add

```
export PATH="$HOME/global/syms:$PATH"
. "$HOME/global/myshell.sh"
```

to your `.bashrc` or `.zshrc`