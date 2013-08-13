define ["jquery"], ($) ->
	{
		getRoutes: (from, destinations,cb) ->
			routes = destinations.map (dest) ->
				return {
					from:
						lat: from.latitude
						lng: from.longitude
					to:
						lat: dest.lat
						lng: dest.lng
				}


			$.ajax
				url: "http://" + window.location.hostname + ":3000/route"
				method:"POST"
				data:
					routes: JSON.stringify(routes)
				success: (data) ->
					cb(data)
					console.log data

	}
