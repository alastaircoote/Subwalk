child = require "child_process"
fs = require "fs"
async = require "async"
csv = require "csv"


tempDirectory = "/tmp"

class RouteFetch
	cmdDirectory: "/Users/alastair/Projects/Subwalk/routino/routino-2.6/web/bin/"
	command: "router"

	constructor: (route, @cb, @index) ->
		@from = route.from
		@to = route.to

		key = new Date().valueOf() + "-" + @index

		@workingDirectory = tempDirectory + "/#{key}"

		async.series [
			@createOutputDirectory
			@runProcess
			@transformRoute
			@sendResponse
			@deleteFiles
		], (err,rets) ->
			console.log err

	createOutputDirectory: (cb) =>
		fs.mkdir @workingDirectory, (err) ->
			cb(err)

	runProcess: (cb) =>
		args = [
			"--transport=foot"
			"--dir=#{@cmdDirectory}../data"
			"--output-text-all"
			"--output-gpx-track"
			"--lon1=#{@from.lng}"
			"--lat1=#{@from.lat}"
			"--lon2=#{@to.lng}"
			"--lat2=#{@to.lat}"
		]

		@process = child.spawn @cmdDirectory + @command, args, {cwd: @workingDirectory}

		@process.on "error", (err) =>
			console.log err
			cb(err, null)

		@process.on "close", () =>
			cb()

	transformRoute: (cb) =>
		@steps = []

		keepAsText = ["highway", "type"]

		columns = [
			"latitude"
			"longitude"
			"node"
			"type"
			"segment-dist"
			"segment-duration"
			"total-dist"
			"total-duration"
			"speed"
			"bearing"
			"highway"
		]

		csv()
			.from.path(@workingDirectory + "/shortest-all.txt", {
				delimiter:"\t"
				ltrim:true
				comment: "#"
				columns: columns
			})
			#.transform (row) ->


			.on "record", (row) =>
				for key in columns
					if keepAsText.indexOf(key) > -1 then continue

					row[key] = parseFloat row[key]
				@steps.push row
			.on "end", () ->
				cb()

	sendResponse: (cb) =>
		if @cb then @cb(null, @steps)

	deleteFiles: (cb) =>
		async.series [
			(icb) =>
				# Delete file
				fs.unlink @workingDirectory + "/shortest-all.txt", (err,y) ->
					icb(err)
			(icb) =>
				# Delete directory
				fs.rmdir @workingDirectory, (err,y) ->
					icb(err)
		], (err, results) ->
			console.log err, results


		


		
module.exports = RouteFetch
			


#new RouteFetch({from:{lat:40.75447, lng:-73.99056},to:{lat:40.75008, lng:-73.99425}},null,1)

#module.exports.getRoutes (routes, cb) ->

