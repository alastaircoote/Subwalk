define ["vendor/latlon"], (LatLng) ->
	class LatLngBounds

		constructor: (@ne,@sw) ->

		@fromLatLng: (latlng, distance) ->
			ne = latlng.destinationPoint 45, distance / 1000
			sw = latlng.destinationPoint 225, distance / 1000
			console.log ne, sw
			return new LatLngBounds ne, sw

		contains: (latlng) =>
			latMin = Math.min(@ne._lat, @sw._lat)
			lngMin = Math.min(@ne._lon, @sw._lon)

			

			latMax = Math.max(@ne._lat, @sw._lat)
			lngMax = Math.max(@ne._lon, @sw._lon)

			console.log latMin, latMax

			return latlng._lat <= latMax && latlng._lat >= latMin && latlng._lon <= lngMax && latlng._lon >= lngMin
