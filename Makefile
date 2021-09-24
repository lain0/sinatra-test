# source .env && echo $SERVER_IP &&
dry-run:	## dry run
	bundle exec cap production deploy --dry-run
run:			## run (rackup)
	rackup
init:
	bundle exec cap production deploy:initial

install-puma-config:
	cap production puma:config

install-puma-systemd:
	cap production puma:systemd:config puma:systemd:enable
