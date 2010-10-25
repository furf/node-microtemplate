var sys    = require('sys'),
    fs     = require('fs'),
    crypto = require('crypto'),
    yui    = require('yui-compressor');


function MicroTemplateBundle (templates, compileDir) {

  this.templates  = templates;
  this.compileDir = compileDir;

  this.compiledSource;
}


MicroTemplateBundle.prototype = {

  /**
   * 
   * 
   * @param {function} callback function to be executed when asynchronous
   *                   operations are complete 
   * @public
   */
  compile: function (callback) {

    var self = this;

    self._checkTemplates(function (err, useCached) {

      if (err) {
        callback(err, self);
      } else {
        if (useCached) {
          self._readCompiledFile(function (err) {
            if (err) {
              self._compileTemplates(function (err) {
                if (err) {
                  callback(err, self);
                } else {
                  self._compress(function (err) {
                    if (err) {
                      callback(err, self);
                    } else {
                      self._writeCompiledFile(function (err) {
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
          self._compileTemplates(function (err) {
            if (err) {
              callback(err, self);
            } else {
              self._compress(function (err) {
                if (err) {
                  callback(err, self);
                } else {
                  self._writeCompiledFile(function (err) {
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

  /**
   * 
   * 
   * @param {function} callback function to be executed when asynchronous
   *                   operations are complete 
   * @public
   */
  _createHash: function () {

    var md5DigestKey = this.templates.map(function (template) {
      return template.rendererFile;
    }).sort().join('');

    return crypto.createHash('md5').update(md5DigestKey).digest('hex');
  },

  /**
   * Read the compiled file
   *
   * @param {function} callback function to be executed when asynchronous
   *                   file read operation is complete 
   * @private
   */
  _readCompiledFile: function (callback) {

    var self = this,
        file = self.compileDir + '/' + self._createHash();

    fs.readFile(file, 'utf-8', function (err, data) {
      if (err) {
        callback(err, self);
      } else {
        
        // Store compiled source
        self.compiledSource = data;
        
        callback(null, self);
      }
    });
  },

  /**
   * Write the compiled file
   *
   * @param {function} callback function to be executed when asynchronous
   *                   file write operation is complete 
   * @private
   */
  _writeCompiledFile: function (callback) {

    var self = this,
        file = self.compileDir + '/' + self._createHash();

    fs.writeFile(file, self.compiledSource, function (err) {
      if (err) {
        callback(err, self);
      } else {
        callback(null);
      }
    });
  },

  /**
   * 
   */
  _compileTemplates: function (callback) {

    var self = this,
        templatesToCompile = this.templates.length,
        out = [];

    self.templates.forEach(function (template) {
      
      template.compile(function (err, renderer) {

        if (err) {
          callback(err, self);
        } else {
          out.push(renderer);
        }

        --templatesToCompile;

        if (!templatesToCompile) {
          self.compiledSource = '(function(window){' + out.join('') + '})(this);';
          callback(null, self);
        }

      });

    });
  },

  /**
   * Use YUI Compressor to minify compiled source
   */
  _compress: function (callback) {

    var self = this;

    yui.compile(self.compiledSource, [], function (compressedSource) {
      self.compiledSource = compressedSource;
      callback(null, self);
    });
  },

  /**
   * 
   */
  _checkTemplates: function (callback) {

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


// Export MicroTemplateBundle class
module.exports = MicroTemplateBundle;
