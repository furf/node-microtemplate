var sys    = require('sys'),
    fs     = require('fs'),
    crypto = require('crypto');


function Template (method, templateName, templateDir, rendererDir) {

  this.method        = method;
  this.templateDir   = templateDir;
  this.templateName  = templateName;
  this.templateFile  = templateDir + '/' + templateName;
  this.template;
  this.rendererDir   = rendererDir;
  this.rendererName;
  this.rendererFile;
  this.renderer;
  this._inited;

};


Template.prototype = {

  /* //

    Check for the existence of a template file

  // */
  statTemplateFile: function (callback) {

    var self = this;

    fs.stat(self.templateFile, function (err, stats) {

      var md5DigestKey;

      if (err) {
        callback(err, self);
      } else {
        md5DigestKey = self.method + self.templateFile + stats.mtime;
        self.rendererName = crypto.createHash('md5').update(md5DigestKey).digest('hex');
        self.rendererFile = self.rendererDir + '/' + self.rendererName;
        callback(null, self);
      }
    });
  },

  /* //

    Check for the existence of a compiled renderer file

  // */
  statRendererFile: function (callback) {

    var self = this;

    fs.stat(self.rendererFile, function (err, stats) {
      if (err) {
        callback(err, self);
      } else {
        callback(null, self);
      }
    });
  },

  /* //

    Read the template file

  // */
  readTemplateFile: function (callback) {

    var self = this;

    fs.readFile(self.templateFile, 'utf-8', function (err, data) {
      if (err) {
        callback(err, self);
      } else {
        self.template = data;
        callback(null, self);
      }
    });
  },

  /* //

    Transform and compile the template data into renderer code

  // */
  compileTemplate: function (callback) {

    var self  = this,
        out   = [],
        props = self.method.split('.'),
        i, n, prop;

    try {

      // Create global namespace
      if (props[0] !== 'window') {
        props.unshift('window');
      }

      // If namespaced, protect existing objects
      for (i = 2, n = props.length; i < n; ++i) {
        prop = props.slice(0, i).join('.');
        out.push(prop + '=' + prop + '||{};');
      }

      // Add method to namespace
      out.push(props.slice(0, ++i).join('.'));

      // Wrap source in closure that will execute rendered template in scope
      // of supplied object
      out.push('=(function(fn){return function(obj){return fn.apply(obj);};})(function(){');
      out.push(self.toSource(self.template));
      out.push('});');

      self.renderer = out.join('');

      callback(null, self);

    } catch (err) {
      callback(err, self);
    }
  },

  /* //

    Transform template data to functional JavaScript source

  // */
  toSource: function (str) {
    return ("var _=[];_.push('" +
      str.replace(/[\r\t\n]/g, " ")
         .split("<%").join("\t")
         .replace(/((^|%>)[^\t]*)'/g, "$1\r")
         .split("'").join("\\'")
         .replace(/\t=\s*(.*?)\s*%>/g, "',$1,'")
         .split("\t").join("');")
         .split("%>").join(";_.push('")
         .split("\r").join("\\'") +
         "');return _.join('');")
         .split("_.push('');").join("");
  },

  /* //

    Write compiled JavaScript renderer function to disk

  // */
  writeRendererFile: function (callback) {

    var self = this;

    fs.writeFile(self.rendererFile, self.renderer, function (err) {
      if (err) {
        callback(err, self);
      } else {
        callback(null, self);
      }
    });
  },

  /* //

    Read compiled JavaScript renderer function

  // */
  readRendererFile: function (callback) {

    var self = this;

    fs.readFile(self.rendererFile, 'utf-8', function (err, data) {
      if (err) {
        callback(err, self);
      } else {
        self.renderer = data;
        callback(null, self.renderer);
      }
    });
  },
  
  /* //

    

  // */
  isRendered: function (callback) {
    
    var self = this;
    
    self.statTemplateFile(function (err, template) {
      if (err) {
        callback(err, self);
      } else {
        self.statRendererFile(function (err, template) {
         callback(null, !err);
        });
      }
    });
  },
  
  compile: function (callback) {
    
    var self = this;
    self.statTemplateFile(function (err) {
      if (err) {
        callback(err, self);
      } else {
        self.statRendererFile(function (err) {
          if (err) {
            self.readTemplateFile(function (err) {
              if (err) {
                callback(err, self);
              } else {
                self.compileTemplate(function (err) {
                  if (err) {
                    callback(err, self);
                  } else {
                    self.writeRendererFile(function (err) {
                      if (err) {
                        callback(err, self);
                      } else {
                        callback(null, self.renderer);
                      }
                    });
                  }
                });
              }
            });
          } else {
            self.readRendererFile(function (err) {
              if (err) {
                callback(err, self);
              } else {
                callback(null, self.renderer);
              }
            });
          }
        });
      }
    });
  }
  
};


module.exports = Template;
