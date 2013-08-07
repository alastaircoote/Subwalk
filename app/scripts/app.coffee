define [
	"jquery"
	"subway/linelist"
	"views/main-map"
	"geo/geolocator"
	],
	($, LineList, MainMap, GeoLocator) ->
		mainMap = new MainMap()
		list = new LineList()

		list.on "stationsLocated", (stations) ->
			mainMap.zoomToStations(stations)



		geoLocator = new GeoLocator {distanceFilter: 50}

		geoLocator.on "locationUpdate", (e) ->

			mainMap.updateTrackingLocation(e)

			if e.coords.accuracy < 200
				list.giveLocation(e)

		geoLocator.start()