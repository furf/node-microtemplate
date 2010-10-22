Create some templates and store them on the server...

**hello.tpl**

  	Hello <em>{%= this.name %}</em>!

**goodbye.tpl**

  	Goodbye, <strong>{%= this.name %}</strong>!

**convo.tpl**

  	{% for (var i in this) { %}
    	{%= bam.renderers.hello(this[i]) %}
  	{% } %}

  	{% for (var i in this) { %}
    	{%= bam.renderers.goodbye(this[i]) %}
  	{% } %}


Request the templates from the server, passing the desired JS variable name as key and path to the template as the value...
In this example, I'm using namespaced variable names, but globals work as well. The entire file is wrapped in a single closure, passing in this (window in the browser), to allow for better compression.

**http://localhost:8000/?bam.renderers.hello=/hello.tpl&bam.renderers.goodbye=/goodbye.tpl&bam.renderers.convo=/convo.tpl**

  	(function(a){a.bam=a.bam||{};a.bam.renderers=a.bam.renderers||{};a.bam.renderers.hello=(function(b){return function(c){return b.apply(c)}})(function(){var b=[];b.push("Hello <em>",this.name,"</em>!");return b.join("")});a.bam=a.bam||{};a.bam.renderers=a.bam.renderers||{};a.bam.renderers.goodbye=(function(b){return function(c){return b.apply(c)}})(function(){var b=[];b.push("Goodbye, <strong>",this.name,"</strong>!");return b.join("")});a.bam=a.bam||{};a.bam.renderers=a.bam.renderers||{};a.bam.renderers.convo=(function(b){return function(c){return b.apply(c)}})(function(){var b=[];for(var c in this){b.push("   ",bam.renderers.hello(this[c])," ")}b.push("  ");for(var c in this){b.push("   ",bam.renderers.goodbye(this[c])," ")}b.push(" ");return b.join("")})})(this);

**(beautified)**

	(function (a) {
	    a.bam = a.bam || {};
	    a.bam.renderers = a.bam.renderers || {};
	    a.bam.renderers.hello = (function (b) {
	        return function (c) {
	            return b.apply(c)
	        }
	    })(function () {
	        var b = [];
	        b.push("Hello <em>", this.name, "</em>!");
	        return b.join("")
	    });
	    a.bam = a.bam || {};
	    a.bam.renderers = a.bam.renderers || {};
	    a.bam.renderers.goodbye = (function (b) {
	        return function (c) {
	            return b.apply(c)
	        }
	    })(function () {
	        var b = [];
	        b.push("Goodbye, <strong>", this.name, "</strong>!");
	        return b.join("")
	    });
	    a.bam = a.bam || {};
	    a.bam.renderers = a.bam.renderers || {};
	    a.bam.renderers.convo = (function (b) {
	        return function (c) {
	            return b.apply(c)
	        }
	    })(function () {
	        var b = [];
	        for (var c in this) {
	            b.push("   ", bam.renderers.hello(this[c]), " ")
	        }
	        b.push("  ");
	        for (var c in this) {
	            b.push("   ", bam.renderers.goodbye(this[c]), " ")
	        }
	        b.push(" ");
	        return b.join("")
	    })
	})(this);


When the script loads (use &lt;script&gt;, $.getScript, or Sexy *wink*), you can render the template by calling the passed function name with the object to render...

**usage**

	console.log(bam.renderers.convo([
	    {name:'dave'},
	    {name:'furf'}
	]));

  	// outputs --> Hello <em>dave</em>! Hello <em>furf</em>! Goodbye, <strong>dave</strong>! Goodbye, <strong>furf</strong>! 
