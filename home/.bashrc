alias pp='pnpm'
alias vi='nvim'
alias vim='nvim'
alias nvim='nvim'
alias helix='hx'

#Git branches
parse_git_branch() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    echo " ( •́ω•̀)♡ ⎇  ${branch} "
  fi
}
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[31m\]$(parse_git_branch)\[\033[00m\]\$ '
