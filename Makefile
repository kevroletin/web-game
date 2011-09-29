debug :
	@echo "***Debug environment***"
	@environment=debug make run_server

production : run_server

run_server :
	@plackup -R app.psgi,Client,config,Game,Include,Model

tags:
	@find -regex "[^#].*.\(pm\|pl\|psgi\)" | etags -

clean_db :
	@rm tmp/test.db
