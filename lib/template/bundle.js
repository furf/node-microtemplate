var sys    = require('sys'),
    fs     = require('fs'),
    crypto = require('crypto'),
    yui    = require('yui-compressor');


function TemplateBundle (templates, compileDir) {

  this.templates  = templates;
  this.compileDir = compileDir;

  this.compiledSource;
}


TemplateBundle.prototype = {

  /* //



  // */
  compile: function (callback) {

    var self = this;

    self.checkTemplates(function (err, useCached) {

      if (err) {
        callback(err, self);
      } else {
        if (useCached) {
          self.readCompiledFile(function (err) {
            if (err) {
              self.compileTemplates(function (err) {
                if (err) {
                  callback(err, self);
                } else {
                  self.compress(function (err) {
                    if (err) {
                      callback(err, self);
                    } else {
                      self.writeCompiledFile(function (err) {
                        if (err) {
                          callback(err, self);
                        } else {
                          callback(null, self.compiledSource);
                        }
                      });
                    }
                  });
                }
              });
            } else {
              callback(null, self.compiledSource);
            }
          });
        } else {
          self.compileTemplates(function (err) {
            if (err) {
              callback(err, self);
            } else {
              self.compress(function (err) {
                if (err) {
                  callback(err, self);
                } else {
                  self.writeCompiledFile(function (err) {
                    if (err) {
                      callback(err, self);
                    } else {
                      callback(null, self.compiledSource);
                    }
                  });
                }
              });
            }
          });
        }
      }

    });
  },


  /* //

    Create a unique md5 hash based on template renderer paths

  // */
  createHash: function () {

    var md5DigestKey = this.templates.map(function (template) {
      return template.rendererFile;
    }).sort().join('');

    return crypto.createHash('md5').update(md5DigestKey).digest('hex');
  },

  /* //



  // */
  readCompiledFile: function (callback) {

    var self = this,
        file = self.compileDir + '/' + self.createHash();

    fs.readFile(file, 'utf-8', function (err, data) {
      if (err) {
        callback(err, self);
      } else {
        self.compiledSource = data;
        callback(null, self);
      }
    });
  },


  /* //



  // */
  writeCompiledFile: function (callback) {

    var self = this,
        file = self.compileDir + '/' + self.createHash();

    fs.writeFile(file, self.compiledSource, function (err) {
      if (err) {
        callback(err, self);
      } else {
        callback(null, self);
      }
    });
  },

  /* //



  // */
  compileTemplates: function (callback) {

    var self = this,
        templatesToCompile = this.templates.length,
        out = ['(function(window){'];

    self.templates.forEach(function (template) {
      
      template.compile(function (err, renderer) {

        if (err) {
          callback(err, self);
        } else {
          out.push(renderer);
        }

        --templatesToCompile;

        if (!templatesToCompile) {
          out.push('})(this);');
          self.compiledSource = out.join('\n');
          callback(null, self);
        }

      });

    });
  },

  compress: function (callback) {

    var self = this;

    yui.compile(self.compiledSource, [], function (compressedSource) {
      self.compiledSource = compressedSource;
      callback(null, self);
    });
  },

  /* //



  // */
  checkTemplates: function (callback) {

    var self              = this,
        templatesToCheck  = this.templates.length,
        templatesToRender = 0;

    self.templates.forEach(function (template) {

      template.isRendered(function (err, isRendered) {

        if (err) {
          callback(err, self);
        } else {

          if (!isRendered) {
            templatesToRender++;
          }

          --templatesToCheck;

          if (!templatesToCheck) {
            callback(null, !templatesToRender);
          }

        }

      });
    });
  }
};


module.exports = TemplateBundle;
