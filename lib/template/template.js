var sys    = require('sys'),
    fs     = require('fs'),
    crypto = require('crypto');


function Template (method, templateName, templateDir, rendererDir) {

  this.method        = method;
  this.templateDir   = templateDir;
  this.templateName  = templateName;
  this.templateFile  = templateDir + '/' + templateName;
  this.templateData;
  this.rendererDir   = rendererDir;
  this.rendererName;
  this.rendererFile;
  this.rendererData;

};

Template.prototype = {

  /**
   * Returns current rendered state (true if renderer file exists)
   *
   * @see TemplateBundle used to determine if cached bundle is still valid
   *
   * @param {function} callback function to be executed when asynchronous
   *                   operations are complete 
   * @public
   */
  isRendered: function (callback) {
    
    var self = this;
    
    self._statTemplateFile(function (err, template) {
      if (err) {
        callback(err, self);
      } else {
        self._statRendererFile(function (err, template) {
         callback(null, !err);
        });
      }
    });
  },
  
  /**
   * Render (or read) and return compiled JavaScript source code
   *
   * @param {function} callback function to be executed when asynchronous
   *                   operations are complete 
   * @public
   */
  compile: function (callback) {
    
    var self = this;
    
    // Check the current state of the template file to determine path to 
    // cached renderer file
    self._statTemplateFile(function (err) {
      if (err) {
        callback(err, self);
      } else {

        // Check for existence of a renderer file reflecting the current state
        // of the template file
        self._statRendererFile(function (err) {

          // If renderer file doesn't exist, read and compile the template
          // file
          if (err) {
            self._readTemplateFile(function (err) {
              if (err) {
                callback(err, self);
              } else {
                
                // Compile template data to JavaScript source
                self._compileTemplate(function (err) {
                  if (err) {
                    callback(err, self);
                  } else {
                    
                    // Save compiled renderer function to disk
                    self._writeRendererFile(function (err) {
                      if (err) {
                        callback(err, self);
                      } else {
                        
                        // Return renderer source
                        callback(null, self.rendererData);
                      }
                    });
                  }
                });
              }
            });
          
          // If cached renderer file exists, read and return the renderer
          // source code
          } else {
            self._readRendererFile(function (err) {
              if (err) {
                callback(err, self);
              } else {

                // Return renderer source
                callback(null, self.rendererData);
              }
            });
          }
        });
      }
    });
  },

  /**
   * Check for the existence of a template file
   *
   * @param {function} callback function to be executed when asynchronous
   *                   file stat operation is complete 
   * @private
   */
  _statTemplateFile: function (callback) {

    var self = this;

    fs.stat(self.templateFile, function (err, stats) {

      var md5DigestKey;

      if (err) {
        callback(err, self);
      } else {
        
        // Generate a unique key for this template by using the method name,
        // the absolute path to the template file, and the template file's
        // modification date.
        md5DigestKey = self.method + self.templateFile + stats.mtime;
        self.rendererName = crypto.createHash('md5').update(md5DigestKey).digest('hex');
        
        // Set target path for renderer file
        self.rendererFile = self.rendererDir + '/' + self.rendererName;
        
        callback(null, self);
      }
    });
  },

  /**
   * Check for the existence of a compiled renderer file
   *
   * @param {function} callback function to be executed when asynchronous
   *                   file stat operation is complete 
   * @private
   */
  _statRendererFile: function (callback) {

    var self = this;

    fs.stat(self.rendererFile, function (err, stats) {
      if (err) {
        callback(err, self);
      } else {
        callback(null, stats);
      }
    });
  },

  /**
   * Read the template file
   *
   * @param {function} callback function to be executed when asynchronous
   *                   file read operation is complete 
   * @private
   */
  _readTemplateFile: function (callback) {

    var self = this;

    fs.readFile(self.templateFile, 'utf-8', function (err, data) {
      if (err) {
        callback(err, self);
      } else {

        // Store template data
        self.templateData = data;

        callback(null, self.templateData);
      }
    });
  },

  /**
   * Transform and compile template data into renderer code
   *
   * @param {function} callback function to be executed when template
   *                   compilation is complete
   * @private
   */
  _compileTemplate: function (callback) {

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
      out.push(self._toSource(self.templateData));
      out.push('});');

      self.rendererData = out.join('');

      callback(null, self.rendererData);

    } catch (err) {
      callback(err, self);
    }
  },

  /**
   * Transform template data to functional JavaScript source
   *
   * @param {string} tpl uncompiled template data
   * @private
   */
  _toSource: function (tpl) {
    return ("var _=[];_.push('" +
      tpl.replace(/[\r\t\n]/g, " ")
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

  /**
   * Write compiled JavaScript renderer function to disk
   *
   * @param {function} callback function to be executed when asynchronous
   *                   file write operation is complete 
   * @private
   */
  _writeRendererFile: function (callback) {

    var self = this;

    fs.writeFile(self.rendererFile, self.rendererData, function (err) {
      if (err) {
        callback(err, self);
      } else {
        callback(null);
      }
    });
  },

  /**
   * Read compiled JavaScript renderer function
   *
   * @param {function} callback function to be executed when asynchronous
   *                   file read operation is complete 
   * @private
   */
  _readRendererFile: function (callback) {

    var self = this;

    fs.readFile(self.rendererFile, 'utf-8', function (err, data) {
      if (err) {
        callback(err, self);
      } else {
        
        // Store renderer data
        self.rendererData = data;
        
        callback(null, self.rendererData);
      }
    });
  }
  
};

// Export Template
module.exports = Template;