/**
 *  class Slide
**/
var Slide = Class.create({
  /**
   *  new Slide();
  **/
  initialize: function(element, app) {
    this.element = element;
    this.type = this.element.readAttribute("data-type");
    this.app = app;
    
    // HACK!!!
    this.element.select("img").each(function(img) {
      var src = img.readAttribute("src");
      if (src.startsWith("images/")) img.writeAttribute("src", "default/" + src);
    });
    
    var id = this.element.down("h1");
    if (!id) {
      id = "slide-" + this.app.slides.indexOf(this);
    } else {
      id = id.innerHTML.stripTags().strip().toLowerCase()
        .replace(/[\s-]+/g, '_')
        .replace(/\W/g, '')
        .replace(/^\d+/g, '')
        .replace(/_/g, '-');
    }
    
    this.element.id = id;
    
    var handler = this.element.readAttribute("data-handler") || undefined;
    var useDefault = false;
    
    if (handler) {
      if (handler in Application.Transitions) {
        handler = Application.Transitions[handler];
      } else {
        var parts = handler.split('.');
        var obj = window;
        parts.each(function(p) {
          if (obj[p]) {
            obj = obj[p];
          } else throw new Error("Handler not found: " + handler);
        });

        if (obj == window) {
          useDefault = true;
        } else handler = obj;
      }

    } else useDefault = true;
    
    var play = ((useDefault) ? Application.Transitions.fade : handler).bind(this);
    this.play = function() {
      location.hash = id;
      play();
    }.bind(this);
    
    this.hide();
  },
  
  show: function() {
    this.element.show();
    return this;
  },

  hide: function() {
    this.element.hide();
    return this;
  },
  
  queue: function() {
    this.app.queue(this);
    return this;
  },
  
  dequeue: function() {
    this.app.dequeue(this);
    return this;
  },

  toString: function() { return "[object Slide]"; }
});

Slide.all = function(divs, app) {
  var result = [];
  divs.each(function(d) { result.push(new Slide(d, app)); });
  return result;
};