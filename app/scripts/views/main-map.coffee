define [
	"vendor/leaflet"
	"geo/latlngbounds"
	], (L,LatLngBounds) ->
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
			console.log stations
			stationPoints = stations.map (s) -> [s.lat, s.lng]

			stationBounds = new L.LatLngBounds stationPoints

			@map.fitBounds stationBounds, {animate:true}