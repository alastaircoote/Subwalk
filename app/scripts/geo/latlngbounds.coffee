define ["vendor/latlon"], (LatLng) ->
	class LatLngBounds

		constructor: (@ne,@sw) ->

		@fromLatLng: (latlng, distance) ->
			if latlng instanceof Array
				latlng = new LatLng(latlng[0], latlng[1])
			ne = latlng.destinationPoint 45, distance / 1000
			sw = latlng.destinationPoint 225, distance / 1000
			return new LatLngBounds ne, sw

		contains: (latlng) =>
			latMin = Math.min(@ne._lat, @sw._lat)
			lngMin = Math.min(@ne._lon, @sw._lon)

			latMax = Math.max(@ne._lat, @sw._lat)
			lngMax = Math.max(@ne._lon, @sw._lon)

			return latlng._lat <= latMax && latlng._lat >= latMin && latlng._lon <= lngMax && latlng._lon >= lngMin
