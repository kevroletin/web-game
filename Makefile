debug :
	@echo "***Debug environment***"
	@environment=debug make run_server

production : run_server

run_server :
	@plackup -E deployment -R app.psgi,Client,config,Game,Include,Model

tags:
	@find -regex "[^#].*.\(pm\|pl\|psgi\|t\)" | etags -

clean_db :
	@rm tmp/test.db
