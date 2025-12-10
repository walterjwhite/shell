lib io/file.sh
lib net/public-ip.sh

_stunnel_client_ip() {
	_public_ip || _ERROR "Unable to determine public IP"

	SELF_CLIENT_IP=$PUBLIC_IP
	unset PUBLIC_IP

	_require "$SELF_CLIENT_IP" SELF_CLIENT_IP
}

_stunnel_firewall_cleanup() {
	[ -n "$STUNNEL_PID" ] && kill -9 $STUNNEL_PID
	[ -n "$WEB_BROWSER_PID" ] && kill -9 $WEB_BROWSER_PID

	_WARN "Cleaning up stunnel"
	publish-cmd -functionName _stunnel_stop
}

_stunnel_firewall_update() {
	_WARN "Updating firewall to allow stunnel client"

	publish-cmd -functionName _stunnel_start -arguments "$SELF_CLIENT_IP"
}

_stunnel_firewall_wait_conf() {
	_INFO "Waiting 5s for remote server to implement changes"
	sleep 5
}

_stunnel_client_update_conf() {
	_require_file ~/.config/walterjwhite/shell/stunnel.conf

	grep -qm1 '^connect = .*$' ~/.config/walterjwhite/shell/stunnel.conf
	if [ $? -eq 0 ]; then
		$_CONF_GNU_SED -i "s/connect.*/connect = $REMOTE_SERVER_IP:$_CONF_STUNNEL_REMOTE_PORT/" ~/.config/walterjwhite/shell/stunnel.conf
	else
		printf 'connect = %s:%s\n' "$REMOTE_SERVER_IP" "$_CONF_STUNNEL_REMOTE_PORT" >>~/.config/walterjwhite/shell/stunnel.conf
	fi
}

_STUNNEL_CLIENT_RUN_WEB() {
	stunnel ~/.config/walterjwhite/shell/stunnel-web.conf &
	STUNNEL_PIDS="$STUNNEL_PIDS $!"

	web-browser -http-proxy=127.0.0.1:8888 &
	STUNNEL_PIDS="$STUNNEL_PIDS $!"
}

_STUNNEL_CLIENT_RUN_SSH() {
	stunnel ~/.config/walterjwhite/shell/stunnel-ssh.conf &
	STUNNEL_PIDS="$STUNNEL_PIDS $!"
}

_stunnel_client_wait() {
	_INFO "running $STUNNEL_PIDS, hit CTRL+C to abort"
	wait $STUNNEL_PIDS
}
