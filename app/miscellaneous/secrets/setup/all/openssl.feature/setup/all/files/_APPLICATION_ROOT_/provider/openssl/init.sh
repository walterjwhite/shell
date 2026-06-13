lib git/mirror.sh

cfg feature:.
cfg git

[ ! -e $HOME/.openssl-store ] && {
  git clone $optn_git_mirror/secrets-openssl-store.git $HOME/.openssl-store || {
    git init $HOME/.openssl-store
    cd $HOME/.openssl-store

    touch .placeholder
    git add .placeholder
    git commit -am 'init'

    _git_setup_mirror $optn_git_mirror/secrets-openssl-store.git && git push
  }
}

cd $HOME/.openssl-store
