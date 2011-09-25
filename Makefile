build :
	@plackup -R app.psgi,Client,config,Game,Include,Model

tags:
	@find -regex "[^#].*.\(pm\|pl\|psgi\)" | etags -

clean_db :
	@rm tmp/test.db
