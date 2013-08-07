define ["geo/geolocator","async","jquery","geo/latlngbounds","vendor/latlon"] , (Geolocator,async,$,LatLngBounds,LatLng) ->

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

		pos = new LatLng(location.coords.latitude, location.coords.longitude)

		bounds = LatLngBounds.fromLatLng pos, 1000

		nearby = stations.filter (s) ->
			stationLL = new LatLng s.lat, s.lng
			return bounds.contains(stationLL)

		console.log nearby


	
