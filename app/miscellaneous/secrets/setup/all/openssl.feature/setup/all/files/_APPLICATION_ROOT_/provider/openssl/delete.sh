. __LIBRARY_PATH__/__APPLICATION_NAME__/provider/$conf_secrets_provider/init.sh

git rm -rf $1 && git commit $1 -m "remove - $1" && git push
