// http://mahoney.eu/2012/01/04/web-server-on-the-fly-node-js/#.UYKNjsrvzeM

var util = require('util'),
    connect = require('connect'),
    port = 2013;

connect.createServer(connect.static(__dirname + '/app')).listen(port);
util.puts('Listening on ' + port + '...');
util.puts('Press Ctrl + C to stop.');
