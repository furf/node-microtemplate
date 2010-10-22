var sys         = require('sys'),
    http        = require('http'),
    url         = require('url'),
    qs          = require('querystring'),
    fs          = require('fs'),
    crypto      = require('crypto'),
    yui         = require('./lib/yui-compressor'),
    template    = require('./lib/template'),
    templateDir = __dirname + '/templates/';
    cacheDir    = __dirname + '/cache/';

http.createServer(function (req, res) {

  var query     = url.parse(req.url).query,
      digest    = crypto.createHash('md5').update(query).digest('hex'),
      params    = qs.parse(query),
      varName,
      fileCount = 0,
      out = ['(function(window){'],
      source;

  fs.readFile(cacheDir + digest, 'utf-8', function (err, cachedTpl) {
    if (err) {
      
      function loadTemplate (varName, fileName) {

        var filePath = templateDir + fileName;
        fileCount++;

        fs.readFile(filePath, 'utf-8', function (err, tpl) {

          if (err) {
            throw err;
          }

          fileCount--;

          out.push(template.process(varName, tpl));

          if (!fileCount) {
            out.push('})(this);');
            source = out.join('');


            yui.compile(source, [], function (result) {

              fs.writeFile(cacheDir + digest, result, function (err) {
                if (err) {
                  throw err;
                }
                res.writeHead(200, {'Content-Type': 'text/javascript'});
                res.end(result);
              });
              
            });
          }

        });

      }

      for (varName in params) {
        loadTemplate(varName, params[varName]);
      }
      
    } else {
      res.writeHead(200, {'Content-Type': 'text/javascript'});
      res.end(cachedTpl);
      
    }
  });

}).listen(8000);
