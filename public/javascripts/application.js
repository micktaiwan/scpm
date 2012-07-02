// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function confirm_page_change() {
  alert('test');
  }

function createCookie(name,value,days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
}

function eraseCookie(name) {
    createCookie(name,"",-1);
}

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
      if(value=='ci_projects')  location = '/ci_projects';
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
      $('timeline').update(r.responseText);
      $('loading').hide();
      }
    });

  }

function deploy_question(id,value) {
  value = (value==true? 1 : 0)
  new Ajax.Updater('q_'+id, '/generic_risk_questions/deploy', {
    parameters: { id: id, value: value }
    });
  }

function check_requirement(form) {
  if($('req_req_category_id').value=="") {
    alert('Category can not be blank');
    return false;
    }
  if($('req_req_wave_id').value=="") {
    alert('Wave can not be blank');
    return false;
    }
  return true;
  }

function check_list_per_wp(){
  $$('.milestone_title').each(function(item,index){
    if (item.next("ul") && (item.next("ul").childElements().length==0))
    {
      item.hide();
      //console.log(item.innerHTML + "--->" + item.next("ul").childElements());
    }
  });
		// $$('.checklist_item_template_title').each(function(item,index){
		// 		console.log(item.select("ul")[0]);
		// 	if (item.select("ul").length > 1 && (item.select("ul")[0].childElements().length==0))
		// 	{
		// 		//item.hide();
		// 		console.log(item.innerHTML + "--->" + item.next("ul").childElements());
		// 	}
		// });
}
