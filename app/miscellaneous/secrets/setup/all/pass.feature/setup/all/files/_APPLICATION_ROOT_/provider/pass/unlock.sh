secret_key=$(. __APP_PLATFORM_PATH__/apps/__APPLICATION_NAME__/provider/$conf_secrets_provider/find.sh | head -1)
pass show $secret_key >/dev/null 2>&1
