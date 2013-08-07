define ["backbone","underscore","vendor/latlon"], (Backbone, _, LatLng) ->
	class Geolocator
		constructor: (opts) ->
			_.extend(@, Backbone.Events)
			@watchId = null

			@opts = opts || {}

		_started: () ->
			@watchId != null

		start: (fresh) =>
			if @_started() then return

			successFunction = if fresh then @_positionReceived else @_firstPosition
			maximumAge = if fresh then 0 else 60000

			@watchId = navigator.geolocation.watchPosition successFunction, @_error,
				#enableHighAccuracy: true
				maximumAge: maximumAge

		stop: () =>
			navigator.geolocation.clearWatch(@watchId)
			@watchId = null

		_firstPosition: (e) =>
			# First one might be a cached one (which we want) so let's reset and get a fresh coordinate.

			@lastUpdate = e
			@trigger "locationUpdate", e
			@stop()
			@start(true)

		_positionReceived: (e) =>
			if @opts.distanceFilter && @lastUpdate

				lastLatLng = new LatLng(@lastUpdate.coords.latitude, @lastUpdate.coords.longitude)
				newLatLng = new LatLng(e.coords.latitude, e.coords.longitude)
				distance = lastLatLng.distanceTo(newLatLng) * 1000

				if distance < @opts.distanceFilter
					return

			@trigger "locationUpdate", e

		_error: (err) ->
			console.log err