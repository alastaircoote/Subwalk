define [
	"vendor/leaflet"
	"geo/latlngbounds"
	"utils/anim"
	"backbone"
	"views/buttonlayer"
	"subway/colors"
	], (L,LatLngBounds,RequestAnimFrame, Backbone,ButtonLayer,SubwayColors) ->
	class MainMap
		constructor: () ->
			_.extend(@, Backbone.Events)

			@el = $('#main-map')

			@map = L.map('main-map', {
				dragging: true
				touchZoom: true
				zoomControl: false
				doubleClickZoom: false
				attributionControl: false
				scrollWheelZoom: false
			}).fitBounds(new L.LatLngBounds([40.794, -73.920], [40.686, -74.029]))

			@map.options.zoomAnimationThreshold = 9999

			L.tileLayer('http://{s}.tiles.mapbox.com/v3/alastaircoote.map-xgyabfvz/{z}/{x}/{y}.png', {
			    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
			    detectRetina: true
			}).addTo(@map)


		updateTrackingLocation: (e) =>
			#return @map.panTo [e.coords.latitude, e.coords.longitude], {animate:true}
			
		expandAndGoToBounds: (bounds) =>

			# We want to resize the map (smaller), so the bounds we calculate need to be bigger than
			# what we actually want

			startZoom = @map.getBoundsZoom bounds, false 

			amount = $(window).height() * 0.75

			nePx = @map.project bounds.getNorthEast(), startZoom
			swPx = @map.project bounds.getSouthWest(), startZoom
		
			nePx = nePx.subtract [0,amount]
			swPx = swPx.add [0,(amount)]

			finalNe = @map.unproject nePx, startZoom
			finalSw = @map.unproject swPx, startZoom

			nb = new L.LatLngBounds finalSw, finalNe

			@map.once "zoomend", () =>
				# Fix for weird Chrome not panning issue
				@map.panBy([1,1])
				#@trigger "zoomedToPosition"
				#@el.css "webkit-transform", "translate3d(0,-#{amount}px,0)"

			@map.setView nb.getCenter(), @map.getBoundsZoom(nb, false), {animate:true}

		zoomToStations: (stations) =>
			stationPoints = stations.map (s) -> [s.lat, s.lng]

			stationBounds = new L.LatLngBounds stationPoints
			@isZooming = true
			@map.once "zoomend", () =>
				@isZooming = false
			

		addRoutes: (routes,stations) =>
	
			allPoints = []

			routes.forEach (route) ->
				for step in route
					allPoints.push [step.latitude, step.longitude]

			allBounds = new L.LatLngBounds allPoints

			@map.once "zoomend", () =>
				@lines = []
				if @isZooming
					
					# If we're zooming, don't do the draw. It doesn't work right.

					@map.once "zoomend", () =>
						@addRoutes(routes,stations)
					return

				

				for route, i in routes
					
					station = stations[i]

					points = route.map (step) ->
						return [step.latitude, step.longitude]

					line = new L.Polyline(points, {color:"white",clickable:false, dashArray:[0,999999]})
					circle = new ButtonLayer(points[points.length-1], station.routesToTrack.map (r) -> SubwayColors[r])

					@lines.push
						line: line
						circle: circle

					line.addTo(@map)
					@map.addLayer circle
					

				

				@animateLines()

			@expandAndGoToBounds(allBounds)

		animateLines: () =>

			idealDuration = 1000

			# Set up our objects
			toIterate = @lines.map (l) ->
				return {
					path: l.line._path
					length: l.line._path.getTotalLength()
					circle: l.circle
				}

			# Find the longest length- this will last the full duration
			maxLength = Math.max(toIterate.map((l) -> l.length)...)

			toIterate.forEach (l) ->
				l.duration = Math.round (l.length / maxLength) * idealDuration

			startTime = Date.now().valueOf()
			
			doAnimate = () =>

				durationSoFar = Date.now().valueOf() - startTime
				for line in toIterate
					if line.duration - 50  < durationSoFar && !line.circle.isActive
						line.circle.goActive()

					progress = durationSoFar / line.duration
					
					drawLength = line.length * progress
					stillLeft = line.length - drawLength + 10

					$(line.path).attr "stroke-dasharray", [drawLength,stillLeft].join(",")

				if durationSoFar < idealDuration
					RequestAnimFrame(doAnimate)
				else
					@trigger "linesDrawn"

			doAnimate()
