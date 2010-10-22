function wrap (varName, source) {

  var out   = [],
      parts = varName.split('.'),
      i,
      n,
      prop;

  if (parts[0] !== 'window') {
    parts.unshift('window');
  }

  for (i = 2, n = parts.length; i < n; ++i) {
    prop = parts.slice(0, i).join('.');
    out.push(prop + '=' + prop + '||{};\n');
  }

  out.push(parts.slice(0, ++i).join('.'));
  out.push('=(function(fn){\n\treturn function(obj){\n\t\treturn fn.apply(obj);\n\t};\n})(function(){');
  out.push(source.replace("_.push('');", '', 'g'));
  out.push('});\n');

  return out.join('');
}

function toSource (str) {
  return "var _=[];_.push('" +
    str.replace(/[\r\t\n]/g, " ")
       .split("{%").join("\t")
       .replace(/((^|%\})[^\t]*)'/g, "$1\r")
       .split("'").join("\\'")
       .replace(/\t=\s*(.*?)\s*%\}/g, "',$1,'")
       .split("\t").join("');")
       .split("%}").join(";_.push('")
       .split("\r").join("\\'") +
       "');return _.join('');";
}

var template = module.exports = {

  process: function (varName, template) {
    return wrap(varName, toSource(template));
  }

};
