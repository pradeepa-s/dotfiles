export CSCOPE_EDITOR=vim

# Pradeepa's aliases goes here:
alias tmux='tmux -2'
alias foo=fe
alias gs='git status -uno'
alias gp='git pull'
alias gcm='git commit -m '

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}


# FZF shortcuts
# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
fo() {
	local out file key
	IFS=$'\n' out=("$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)")
	key=$(head -1 <<< "$out")
	file=$(head -2 <<< "$out" | tail -1)
	if [ -n "$file" ]; then
		[ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
	fi
}

# fuzzy grep open via ag with line number
vg() {
  local file
  local line

  read -r file line <<<"$(ag --nobreak --noheading $@ | fzf -0 -1 | awk -F: '{print $1, $2}')"

  if [[ -n $file ]]
  then
     vim $file +$line
  fi
}


PATH=~/bin:$PATH
# RESMED aliases goes here:
alias git='/cygdrive/c/Program\ Files/Git/mingw64/bin/git'
alias ss='wscons -uj8'
alias fg1='cd /home/pradeepas/fgrepo/1/fgapplication'
alias fg2='cd /home/pradeepas/fgrepo/2/fgapplication'
alias fg3='cd /home/pradeepas/fgrepo/3/fgapplication'
alias fgm='cd /home/pradeepas/fgrepo/master/fgapplication'
alias fgf='cd /home/pradeepas/fgrepo/figshell/Figshell'
alias w32='cd Test/Scenarios/Win32'
alias target='cd Test/Scenarios/Target'
alias gsu='git submodule update'
alias gsr='git submodule update --init --recursive'
alias fgclone='git clone http://bitbucket.corp.resmed.org/scm/pac/fgapplication.git'
alias fgs='git pull && gsr && cd Test/Scenarios/Win32 && ss && cd ../Target && ss && cd ../../Unit/SuperUnit/Win32 && ss && ./Unit_NoRegion_SupersetAlert.exe'
alias fgmsetup='mkdir -p /home/pradeepas/fgrepo/master && cd /home/pradeepas/fgrepo/master && fgclone && fgm && fgs && fgm'
alias fg1setup='mkdir -p /home/pradeepas/fgrepo/1 && cd /home/pradeepas/fgrepo/1 && fgclone && fg1 && fgs && fgm'
alias fg2setup='mkdir -p /home/pradeepas/fgrepo/2 && cd /home/pradeepas/fgrepo/2 && fgclone && fg2 && fgs && fgm'
alias fg3setup='mkdir -p /home/pradeepas/fgrepo/3 && cd /home/pradeepas/fgrepo/3 && fgclone && fg3 && fgs && fgm'
alias fgfsetup='mkdir -p /home/pradeepas/fgrepo/figshell && cd /home/pradeepas/fgrepo/figshell && git clone http://bitbucket.corp.resmed.org/scm/ssw/figshell.git'
alias fgsetup='fgmsetup && fg1setup && fg2setup && fg3setup'
alias fgms='fgm && fgs'
alias fg1s='fg1 && fgs'
alias fg2s='fg2 && fgs'
alias fg3s='fg3 && fgs'
alias fgas='fgms && fg1s && fg2s && fg3s'
alias fgtt='python fgtest.py -t -J ~/Hw.py -s '
alias fgt='python fgtest.py -s '
