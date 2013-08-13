define [
	"vendor/leaflet"
	"geo/latlngbounds"
	"utils/anim"
	], (L,LatLngBounds,RequestAnimFrame) ->
	class MainMap
		constructor: () ->
			@map = L.map('main-map', {
				dragging: false
				touchZoom: false
				zoomControl: false
				doubleClickZoom: false
				attributionControl: false
				scrollWheelZoom: false
			}).fitBounds(new L.LatLngBounds([40.794, -73.920], [40.686, -74.029]))

			L.tileLayer('http://{s}.tiles.mapbox.com/v3/alastaircoote.map-xgyabfvz/{z}/{x}/{y}.png', {
			    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
			    detectRetina: true
			}).addTo(@map)


		updateTrackingLocation: (e) =>
			return @map.panTo [e.coords.latitude, e.coords.longitude], {animate:true}
			###
			bounds = LatLngBounds.fromLatLng([e.coords.latitude, e.coords.longitude], e.coords.accuracy)
			console.log bounds
			llBounds = new L.LatLngBounds [bounds.ne._lat, bounds.ne._lon], [bounds.sw._lat, bounds.sw._lon]
			console.log llBounds
			@map.fitBounds llBounds
			###

		zoomToStations: (stations) =>
			stationPoints = stations.map (s) -> [s.lat, s.lng]

			stationBounds = new L.LatLngBounds stationPoints

			@map.fitBounds stationBounds, {animate:true}

		addRoutes: (routes) =>
			@lines = []
			for route in routes
				
				points = route.map (step) ->
					return [step.latitude, step.longitude]

				line = new L.Polyline(points, {color:"white",clickable:false, dashArray:[0,999999]})
				@lines.push line

				line.addTo(@map)

			@animateLines()

		animateLines: () =>

			idealDuration = 1000

			# Set up our objects
			toIterate = @lines.map (l) ->
				return {
					path: l._path
					length: l._path.getTotalLength()
				}

			# Find the longest length- this will last the full duration
			maxLength = Math.max(toIterate.map((l) -> l.length)...)

			console.log "max length is " + maxLength

			toIterate.forEach (l) ->
				l.duration = Math.round (l.length / maxLength) * idealDuration

			startTime = Date.now().valueOf()
			console.log toIterate
			
			doAnimate = () ->

				durationSoFar = Date.now().valueOf() - startTime
				console.log "duration", durationSoFar
				for line in toIterate
					if line.duration < durationSoFar then continue

					progress = durationSoFar / line.duration
					console.log "progress", progress

					drawLength = line.length * progress
					stillLeft = line.length - drawLength

					$(line.path).attr "stroke-dasharray", [drawLength,stillLeft].join(",")

				if durationSoFar < idealDuration
					RequestAnimFrame(doAnimate)

			doAnimate()
			return

			lineLength = Math.ceil(line._path.getTotalLength())

			$(line._path).attr "stroke-dasharray", "0," + lineLength
			
			startTime = Date.now().valueOf()
			targetTime = startTime + 2000
			doAnimate = () ->
				soFar = Date.now().valueOf() - startTime
				percent = Math.floor((soFar / 2000) * 100)
				drawLength = lineLength * (percent / 100)
				stillLeft = lineLength - drawLength

				

				if percent < 100 then RequestAnimFrame(doAnimate)

			doAnimate()
