//= require <prototype/dist/prototype>
//= require <scripty2/dist/s2>
//= require "dom"
//= require "slide"
//= require "application"

var app;

document.on("dom:loaded", function() {
  app = new Application();  
});
