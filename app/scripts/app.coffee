define [
	"jquery"
	"subway/linelist"
	"views/main-map"
	"geo/geolocator"
	"geo/router"
	],
	($, LineList, MainMap, GeoLocator, Router) ->
		#alert $(window).height()

		$("body").css "height", $(window).height() + 60

		setTimeout () ->
	        window.scrollTo(0, 1)
	    , 1000

		mainMap = new MainMap()
		list = new LineList()

		currentLocation = null

		list.on "stationsLocated", (stations) ->
			Router.getRoutes currentLocation.coords, stations, (routes) ->
				console.log stations
				mainMap.addRoutes(routes,stations)

			#mainMap.zoomToStations(stations)

		mainMap.on "linesDrawn", () ->
			

			amnt = ($(window).height() * 0.75)/2
			$("#main-map").css "-webkit-transform", "translate3d(0,-#{amnt}px,0)"#.addClass "moveup"
			$("#stop-list").addClass "show"

		geoLocator = new GeoLocator {distanceFilter: 50}

		geoLocator.on "locationUpdate", (e) ->

			mainMap.updateTrackingLocation(e)

			if e.coords.accuracy < 200
				currentLocation = e
				list.giveLocation(e)

		geoLocator.start()