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
/*
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
*/

function change_context() {
  document.body.style.cursor = 'wait';
  value = $('context_select').value
  new Ajax.Request('/application/change_context', {
    parameters: { context: value },
    onComplete: function(r) {
      if(value=='reporting') location = '/projects';
      if(value=='workloads') location = '/workloads';
      if(value=='tools')     location = '/tools/sdp_index';
      if(value=='logout')    location = '/sessions/logout';
      }
    });
  }

function open_checklist(milestone_id) {
  content = $('checklist_popup_content');
  content.innerHTML = "<br/><img src='/images/loading.gif'>";
  popup = $('checklist_popup')
  popup.style.width = "600px";
  popup.show();
  new Ajax.Request('/checklists/show/'+milestone_id, {
    //parameters: { context: value },
    onComplete: function(r) {
      content.innerHTML = r.responseText
      }
    });
  }

function checklist_item_set_next_status(id) {
  $('cl_image_'+id).src = '/images/loading2.gif';
  new Ajax.Request('/checklists/set_next_status', {
    parameters: { id: id}
    });
  }

function refresh_projects(sort) {
  $('loading').show();
  new Ajax.Request('/projects/refresh_projects', {
    parameters: { sort: sort },
    onComplete: function(r) {
      $('frieze').update(r.responseText);
      $('loading').hide();
      }
    });
  
  }