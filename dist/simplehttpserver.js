var express = require('express'),
    path = require('path'),
    url = require('url'),
    fs = require('fs'),
    util = require('util'),
    async = require('async'),
    send = require('send');

var mainapp = express();

// Bodyparser parses HTTP POST parameters and JSON payload
mainapp.use(express.bodyParser());

// Logger for requests
mainapp.use(express.logger());

// Serve either current or directory given as argument
var dir = process.argv[2] || process.cwd();
dir = path.resolve( dir );
mainapp.use(express.static( dir ));

// Add any dynamic handlers here
//mainapp.get('/ajax', function(req, res) {
//   res.send('Query: ' + util.inspect(req.query));
//});
//mainapp.post('/test', function(req, res) {
//   res.send('Parameters: ' + util.inspect(req.body));
//});

// Catch all function when static server did not find any file to serve. In case requested
// file matched directory, this tries to find first index.html and if that fails it builds
// the directory listing.
mainapp.get('*', function(req, res) {
   var pathname = url.parse(req.url).pathname;
   pathname = path.join(dir, pathname);

    fs.stat(pathname, function(err, stat) {
        // Check if path is directory
        if ( !stat || !stat.isDirectory() ) return res.send(404);

        // check for index.html
        var indexpath = path.join(pathname, 'index.html');
        fs.stat(indexpath, function(err, stat) {
           if ( stat && stat.isFile() ) {
               // index.html was found, serve that
               send(res, indexpath)
                   .pipe(res);
               return;

           } else {
               // No index.html found, build directory listing
               fs.readdir(pathname, function(err, list) {
                  if ( err ) return res.send(404);
                  return directoryHTML( res, req.url, pathname, list );
               });
           }
        });
    });
});

// Reads directory content and builds HTML response
function directoryHTML( res, urldir, pathname, list ) {
    var ulist = [];

    function sendHTML( list ) {
        res.setHeader('Content-Type', 'text/html');
        res.send('<!DOCTYPE html>' +
            '<html>\n' +
            '<title>Directory listing for '+urldir+'</title>\n' +
            '<body>\n' +
            '<h2>Directory listing for '+urldir+'</h2>\n' +
            '<hr><ul>\n' +
            list.join('\n') +
            '</ul><hr>\n' +
            '</body>\n' +
            '</html>');
    }

    if ( !list.length ) {
        // Nothing to resolve
        return sendHTML( ulist );
    }

    // Check for each file if it's a directory or a file
    var q = async.queue(function(item, cb) {
        fs.stat(path.join(pathname, item), function(err, stat) {
           if ( !stat ) cb();
           if ( stat.isDirectory() ) {
               ulist.push('<li><a href="'+item+'/">'+item+'/</a></li>')
           } else {
               ulist.push('<li><a href="'+item+'">'+item+'</a></li>')
           }
            cb();
        });
    }, 4);
    list.forEach(function(item) {
        q.push(item);
    });
    q.drain = function() {
       sendHTML(ulist);
    };
}

var port = 2013
// Fire up server
mainapp.listen(port);
console.log('Listening port ' + port + ' root dir ' + dir );

