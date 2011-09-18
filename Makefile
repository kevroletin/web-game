build :
	@plackup -R app.psgi,Client,config,Game,Include,Model

clean_db :
	@rm tmp/test.db
