lib context.sh
lib exec.sh
lib exit.sh
lib feature:.
lib git/data.app.sh
lib include.sh
lib logging.sh
lib mktemp.sh
lib net/hostname.sh
lib stdin.sh
lib time.sh

cfg .
cfg context
cfg feature:.
cfg git
cfg logging
cfg paths
cfg platform

[ -z "$INTERACTIVE" ] && exit

_APPLICATION_NAME=console


_PROJECT_PATH=$_CONF_DATA_PATH/$_APPLICATION_NAME


_WARN=1 _git_init
cd $OLDPWD

HISTSIZE=$_CONF_CONSOLE_ZSH_HISTORY_SIZE
SAVEHIST=$_CONF_CONSOLE_ZSH_HISTORY_SIZE


_console_context

_set_histfile

autoload -U add-zsh-hook
add-zsh-hook precmd _after
add-zsh-hook preexec _before
add-zsh-hook zshexit _save_console_history
