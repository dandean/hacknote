Element.addMethods({
  getTransform: function(element) {
    element = $(element);
    var trans = element.getStyle('transform')
        || element.getStyle('-webkit-transform')
        || element.getStyle('-moz-transform')
        || element.getStyle('-o-transform');
    
    var result = {scale: 1, rotate: 0};
    
    if (trans) {
      var parts = trans.split(" ");
      result.scale = parts[0].match(/[\d\.]+/);
      result.rotate = parts[1].match(/[\d\.]+/);
      if (isNaN(result.rotate)) result.rotate = 0;
    }
    return result;
  }
});