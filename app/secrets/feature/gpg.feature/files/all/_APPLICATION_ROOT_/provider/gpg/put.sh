lib feature/gpg.feature/gpg.sh

[ "$_CONF_SECRETS_OVERWRITE_EXISTING" ] && [ -e $1.gpg ] && rm -f $1.gpg
mkdir -p $(dirname $1)

_PLAINTEXT=$(_mktemp)
printf '%s\n' "$_SECRET_VALUE" >>$_PLAINTEXT

gpg --output $1.gpg --encrypt --recipient $_FEATURE_GPG_USER_EMAIL $_PLAINTEXT
rm -f $_PLAINTEXT
unset _PLAINTEXT

git add $1.gpg
git commit $1.gpg -m "$1"
git push
