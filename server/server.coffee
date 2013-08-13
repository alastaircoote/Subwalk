connect = require "connect"
http = require "connect"
async = require "async"

RouteFetch = require "./route"

app = connect()
app.use connect.bodyParser()

app.use (req,res) ->
	if req.url == "/route"
		routes = JSON.parse(req.body.routes)



		async.map routes, (route,cb) ->

			index = routes.indexOf route
			new RouteFetch(route,cb,index)
		, (err, results) ->
			res.setHeader "Content-Type", "application/json"
			res.setHeader "Access-Control-Allow-Origin", "*"
			res.end JSON.stringify(results)


http.createServer(app).listen(3000)