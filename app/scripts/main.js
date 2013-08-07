require.config({
    paths: {
        jquery: '../bower_components/jquery/jquery',
        backbone: '../bower_components/backbone/backbone',
        underscore: '../bower_components/underscore/underscore',
        async: "../bower_components/async/lib/async"
    },
    shim: {
        'backbone': {
            deps: ['underscore', 'jquery'],
            exports: 'Backbone'
        },
        'underscore': {
            exports: '_'
        },
        "vendor/geo": {
            exports: "Geo"
        },
        "vendor/latlon": {
            exports: "LatLon",
            deps: ["vendor/geo"]
        }
    }
});

require(['app', 'jquery'], function (app, $) {
    'use strict';
    // use app here

});
