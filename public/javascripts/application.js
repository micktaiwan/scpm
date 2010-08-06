// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}

// http://code.google.com/p/simile-widgets/wiki/Timeline_GettingStarted

var tl;

var resizeTimerID = null;
function onResize() {
   if (resizeTimerID == null) {
       resizeTimerID = window.setTimeout(function() {
           resizeTimerID = null;
           tl.layout();
       }, 500);
   }
}
