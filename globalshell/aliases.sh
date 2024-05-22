

alias gpull='git pull origin $BNAME'
alias gpush='git push origin $BNAME'
alias initgshell='. "$HOME/global/init-globalshell.sh"'

alias gcpports='exec gcloud compute --project pict-app \
    ssh --zone us-central1-a webapp-development-cary \
    -- -NL 3000:localhost:3000 -NL 8000:localhost:8000'
alias gcpssh='gcloud compute --project pict-app ssh \
    --zone us-central1-a webapp-development-cary'

alias pyenvinit='export PYENV_ROOT="$HOME/.pyenv" && \
	command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH" \
	&& eval "$(pyenv init -)"'

alias timestamp="python3 -c 'from time import time; print(time() * 1000)'"

alias py3='python3'
alias py='python'

alias shellsh='source shell.sh'

alias git-ssh="git_ssh"

# docker
alias dc='docker compose'
alias dcpruneall='docker image prune -a; docker container prune; docker volume prune; docker network prune'
alias tstime='pytime'

alias gtree='tree -aCF  --charset ascii --filelimit=200 | sed "s/  / /g;s/--/-/g"'

alias ls='ls -AaFp --color=always'
