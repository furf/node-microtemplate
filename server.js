require.paths.push(__dirname + '/lib');

var sys             = require('sys'),
    http            = require('http'),
    url             = require('url'),
    qs              = require('querystring'),

    Template        = require('template'),
    TemplateBundle  = require('template/bundle'),
    
    templateDir = __dirname + '/templates';
    cacheDir    = __dirname + '/cache';



function map (obj, callback) {
  var key, ret, arr = [];
  for (key in obj) {
    ret = callback.call(obj, key, obj[key]);
    if (typeof ret !== 'undefined') {
      arr.push(ret);
    }
  }
  return arr;
}

http.createServer(function (req, res) {

  var s = new Date();
  
  var params = qs.parse(url.parse(req.url).query),

      templates = map(params, function (method, templateName) {
        return new Template(method, templateName, templateDir, cacheDir);
      }),

      templateBundle = new TemplateBundle(templates, cacheDir);
  
  templateBundle.compile(function (err, compiledBundle) {
    var comment = '/* Response time: ' + (new Date() - s) + 'ms */\n';
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end(comment + compiledBundle);    
  });

}).listen(8000);