define [
	"backbone"
	"underscore"
	"geo/geolocator"
	"async"
	"vendor/latlon"
	"geo/latlngbounds"
	], (Backbone,_,GeoLocator, async, LatLng, LatLngBounds) ->
		class LineList extends Backbone.Collection

			@savedTimes:[]

			initialize: () =>

				@_fetchAllStops()

			_fetchAllStops: () =>
				$.get "/data/stop-data.json", (data) =>
					@stops = data
					@stops.forEach (s) ->
						# Create a latlng instance for each
						s.latlng = new LatLng s.lat, s.lng

					if @loc then @giveLocation(@loc) # If we already received then process now

			giveLocation: (e) =>

				@loc = e

				if !@stops then return # We don't have stop data yet

				# Get 1km bounding box
				pos = new LatLng(@loc.coords.latitude, @loc.coords.longitude)
				bounds = LatLngBounds.fromLatLng pos, 1000

				# Find stations that are within this bounding box
				@nearbyStations = @stops.filter((s) -> bounds.contains(s.latlng)).sort (a,b) ->
					pos.distanceTo(a.latlng) - pos.distanceTo(b.latlng)

				@_getStationData()

			_getStationData: () =>
				newStations = @nearbyStations.filter (s) => !LineList.savedTimes[s.code]

				async.map newStations, (station,cb) ->
					$.ajax
						url: "/data/times/#{station.code}_WKD.json.gz"
						dataType: "json"
						success: (data) ->
							cb(null,{code: station.code, times: data})
				, (err,results) =>
					for r in results
						LineList.savedTimes[r.code] = r.times

					@_applyFilterToTimes()

			_applyFilterToTimes: () =>
				rightNowMinute = (new Date().getHours() * 60) + new Date().getMinutes()
				windowEnd = rightNowMinute + 30 # 30 minute window for times

				@nearbyStations.forEach (s) ->

					s.timeWindowStart = rightNowMinute

					# Only keep times within this window

					s.times = LineList.savedTimes[s.code].filter (t) ->
						t.time > rightNowMinute && t.time <= windowEnd

				@_stationsToLines()


			_stationsToLines: () =>

				# We don't want to show duplicate stops if there are multiple stations
				# from the same line nearby. So we filter them out.

				alreadyMapped =
					0: []
					1: []

				finalStations = {}

				@nearbyStations.forEach (station) ->
					station.times.forEach (time) ->
						if alreadyMapped[time.direction].indexOf(time.route) == -1

							alreadyMapped[time.direction].push time.route

							station.routesToTrack = station.routesToTrack || []

							station.routesToTrack.push time.route

							
							finalStations[time.route] = station

				console.log finalStations

				@trigger "stationsLocated", @nearbyStations.filter (s) -> s.routesToTrack


