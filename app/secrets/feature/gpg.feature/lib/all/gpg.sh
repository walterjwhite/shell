lib sed.sh

_SECRETS_GPG_PATH=$_CONF_APPLICATION_DATA_PATH/gpg
_SECRETS_GPG_PATH_SED_SAFE=$(_sed_safe $_SECRETS_GPG_PATH)

mkdir -p $_SECRETS_GPG_PATH
cd $_SECRETS_GPG_PATH
[ ! -e .git ] && {
	git init

	_WARN 'Add a remote to sync secrets'
}
