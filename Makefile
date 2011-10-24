CMD=starman

debug :
	@echo "***Debug environment***"
	@environment=debug make run_server

production : run_server

run_server :
	@$(CMD) -E deployment -R app.psgi,Game,Game.pm

tags:
	@find -regex "./[^#\.].*.\(pm\|pl\|psgi\|t\)" | etags -

clean_db :
	@rm tmp/test.db
