secret_key=$(. __LIBRARY_PATH__/__APPLICATION_NAME__/provider/$conf_secrets_provider/find.sh | head -1)
pass show $secret_key >/dev/null 2>&1
