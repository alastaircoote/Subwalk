define [
	"jquery"
	"subway/linelist"
	"views/main-map"
	"geo/geolocator"
	"geo/router"
	],
	($, LineList, MainMap, GeoLocator, Router) ->
		mainMap = new MainMap()
		list = new LineList()

		currentLocation = null

		list.on "stationsLocated", (stations) ->
			Router.getRoutes currentLocation.coords, stations, (routes) ->
				mainMap.addRoutes(routes)
				
			mainMap.zoomToStations(stations)



		geoLocator = new GeoLocator {distanceFilter: 50}

		geoLocator.on "locationUpdate", (e) ->

			mainMap.updateTrackingLocation(e)

			if e.coords.accuracy < 200
				currentLocation = e
				list.giveLocation(e)

		geoLocator.start()