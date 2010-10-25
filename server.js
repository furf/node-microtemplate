require.paths.push(__dirname + '/lib');
require.paths.push(__dirname + '/lib/vendor');

var sys                 = require('sys'),
    http                = require('http'),
    url                 = require('url'),
    qs                  = require('querystring'),
    MicroTemplate       = require('microtemplate/microtemplate'),
    MicroTemplateBundle = require('microtemplate/microtemplatebundle'),
    
    templateDir         = __dirname + '/data/templates';
    rendererDir         = __dirname + '/data/renderers';


Object.map = function (obj, callback) {
  var key, ret, arr = [];
  for (key in obj) {
    ret = callback.call(obj, key, obj[key]);
    if (typeof ret !== 'undefined') {
      arr.push(ret);
    }
  }
  return arr;
};

http.createServer(function (req, res) {

  var s = new Date();
  
  var query  = url.parse(req.url).query,
      params = qs.parse(query),
      templates,
      bundle;
  
  templates = Object.map(params, function (method, templateName) {
    return new MicroTemplate(method, templateName, templateDir, rendererDir);
  });
  
  bundle = new MicroTemplateBundle(templates, rendererDir);
  
  bundle.compile(function (err, compiledBundle) {
    var comment = '/* Response time: ' + (new Date() - s) + 'ms */\n';
    res.writeHead(200, {'Content-Type': 'text/javascript'});
    res.end(comment + compiledBundle);    
  });

}).listen(8000);
