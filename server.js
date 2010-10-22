var sys         = require('sys'),
    http        = require('http'),
    url         = require('url'),
    qs          = require('querystring'),
    fs          = require('fs'),
    yui         = require('./lib/yui-compressor'),
    template    = require('./lib/template'),
    templateDir = __dirname + '/templates/';

// tmpl.process('bam.renderers.helloWorld', 'Hello, <em>{%= this.name %}</em>');


http.createServer(function (req, res) {

  var query     = url.parse(req.url).query,
      params    = qs.parse(query),
      varName,
      fileName,
      filePath,
      fileCount = 0,
      out = ['(function(window){'],
      source;
  
  sys.log(JSON.stringify(params));


  
  for (varName in params) {
    (function (varName, fileName) {

      filePath = templateDir + fileName;

      fileCount++;

      sys.log('reading ' + filePath);

      fs.readFile(filePath, 'utf-8', function (err, tpl) {
        if (err) throw err;

        out.push(template.process(varName, tpl));

        fileCount--;

        if (!fileCount) {
          out.push('})(this);');
          source = out.join('');
          yui.compile(source, [], function (result) {
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.end(result);
          })
        }

      });
      
    })(varName, params[varName]);
    
    
    
  }

  
}).listen(8081);
console.log('Server running at http://127.0.0.1:8080/');
