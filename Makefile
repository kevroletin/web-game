CMD=starman
CMD=plackup

debug :
	@echo "***Debug environment***"
	@environment=debug make run_server

compability :
	@echo "***Debug environment***"
	@echo "***Compability mode***"
	@environment=debug compability=true make run_server

production : run_server

run_server :
	@$(CMD) -E deployment -R app.psgi,Game.pm,`find -regex "./Game/.*pm" | xargs perl -e 'print join ",", grep { !/AI/ } @ARGV'`


tags:
	@find -regex "./[^#\.].*.\(pm\|pl\|psgi\|t\)" | etags -

clean_db :
	@rm tmp/test.db
