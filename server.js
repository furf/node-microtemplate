var sys         = require('sys'),
    http        = require('http'),
    url         = require('url'),
    qs          = require('querystring'),
    fs          = require('fs'),
    yui         = require('./lib/yui-compressor'),
    template    = require('./lib/template'),
    templateDir = __dirname + '/templates/';

http.createServer(function (req, res) {

  var query     = url.parse(req.url).query,
      params    = qs.parse(query),
      varName,
      fileCount = 0,
      out = ['(function(window){'],
      source;

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
          res.writeHead(200, {'Content-Type': 'text/javascript'});
          res.end(result);
        });
      }

    });

  }

  for (varName in params) {
    loadTemplate(varName, params[varName]);
  }

}).listen(8000);
