define ["geo/geolocator","async","jquery"] , (Geolocator,async,$) ->

	g = new Geolocator {distanceFilter: 50}

	async.parallel [
		
		(cb) ->
			g.on "locationUpdate", (e) ->
				cb(null,e)
				#$("body")[0].innerHTML += e.coords.accuracy
			g.start()

		(cb) ->
			$.get "/data/stop-data.json", (data) ->
				cb(null,data)

	], (err, results) ->
		location = results[0]
		stations = results[1]



	
