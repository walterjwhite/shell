The 'init' app (app/init) presently only supports a single registry with a $local_registry toggle, instead allow the user to specify multiple registries in the form:
<registry_name>|<registry_url>

The '|' will separate the name from the url.
Multiple entries can be added by using a ',' as a delimeter.
Each registry will be installed to $REGISTRY_PATH/<registry_name>

The configuration will default to:
: ${conf_init_app_registries:="default|https://github.com/walterjwhite/app.registry.git"}

replace the existing configuration: conf_install_app_registry_git_url

remove $local_registry as it will be superseded by this.
allow the user to specify which registry to use at runtime, if $use_registry is set, look for the app in that registry
