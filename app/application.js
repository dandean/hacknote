/**
 *  class Application
**/
var Application = Class.create({
  /**
   *  new Application();
  **/
  initialize: function() {
    this.index = 0;
    this.zIndex = 0;

    // This scaling shit's ugly. Need to clean it up!
    var stage = {
      element: $("stage"),
      dims: document.viewport.getDimensions()
    };
    var slide = {
      element: $$("div.slide").first()
    };
    slide.dims = slide.element.getDimensions();
    
    // Center stage in viewport
    stage.element.setStyle({
      left: ((stage.dims.width - slide.dims.width) / 2) + "px",
      top: ((stage.dims.height - slide.dims.height) / 2) + "px"
    });
    
    // First, scale up so height == stage height
    // Then, if it's too big, scale down so width == stage.width
    var ratio = ((stage.dims.height / slide.dims.height) * 1000).floor() / 1000;
    
    this.slides = Slide.all($$("div.slide"), this);
    this.slides[0].show();
    
    stage.element.transform({scale: ratio});
    
    // keyboard navigation
    document.on("keyup", function(e) {
      switch (e.keyCode) {
        case Event.KEY_RIGHT:
        case 34: // page down
          this.next();
          break;
        case Event.KEY_LEFT:
        case 33: // page up
          this.back();
          break;
        case Event.KEY_UP:
        case Event.KEY_HOME:
          this.first();
          break;
        case Event.KEY_DOWN:
        case Event.KEY_END:
          this.last();
          break;
        default: break;
      }
    }.bind(this));
    
    // forward to deep-linked slide.
    var hash = location.hash.replace("#", "");
    if (hash) {
      setTimeout(function() {
        var initial = $$("div#" + hash + ".slide").first();
        if (initial) this.go(initial.previousSiblings().length);
      }.bind(this), 100);
    }
  },
  
  queue: function(slide) {
    this.zIndex++;
    slide.element.style.zIndex = this.zIndex;
    return this;
  },
  
  dequeue: function(slide) {
    slide.element.setStyle({
      zIndex: 0, opacity: 1, display: "none"
    });
    return this;
  },
  
  current: function() {
    return this.slides[this.index];
  },
  
  go: function(index) {
    var current = this.current(),
        next = this.slides[index];
        
    if (next && next != current) {
      next.queue().play();
      this.index = index;
    }
  },
  
  first: function() {
    this.go(0);
  },

  next: function() {
    this.go(this.index + 1);
  },

  back: function() {
    this.go(this.index - 1);
  },

  last: function() {
    this.go(this.slides.length - 1);
  },
  
  toString: function() { return "[object Application]"; }
});

Application.Transitions = {
  fade: function() {
    var current = this.app.current();
    current.element.fade({
      after: function() { current.dequeue(); }.bind(this)
    });
    this.element.setStyle({opacity: 0}).show().morph('opacity:1');
  },
  
  slide: function() {
    var current = this.app.current();
    var stage = $("stage");
    
    var ratio = stage.getTransform().scale;
    var translation = ((1 - ratio) + 1) * document.viewport.getWidth();

    this.element.setStyle({left: translation + "px"}).show().morph('left:0px', {
      duration: 0.5,
      after: function() { current.dequeue(); }.bind(this)
    });
  },
  
  zoom: function() {
    var current = this.app.current();
    throw new Error("not implemented");
  },
  
  bounce: function() {
    var current = this.app.current();
    var stage = $("stage");
    
    this.element.setStyle({top: "-" + stage.measure("height") + "px"}).show().morph('top:0px', {
      transition: 'easeOutBounce',
      duration: 1,
      after: function() { current.dequeue(); }.bind(this)
    });
  }
};
