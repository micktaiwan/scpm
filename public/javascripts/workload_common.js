function wl_add_line() {
  $('wl_line_add_form').appear({duration:0.2});
  window.onkeyup = function (event) {
    if (event.keyCode == 27) {
      $('wl_line_add_form').fade({duration:0.2});
    }
  }
  }

function wl_change_colors(wlweek, background, color) {
  $('cpercent_'+wlweek).style.background  = background;
  $('cpercent_'+wlweek).style.color       = color;
  }
function wl_case_change_colors(line, wlweek, background, color) {
  $(line + '_' + wlweek).style.background  = background;
  $(line + '_' + wlweek).style.color       = color;
  }

function set_fixed_header(max_height) {
  h = $('workload_table').getElementsByTagName("tr").length*22;
  max_height = max_height || 400;
  if(h > max_height) h = max_height;
  $j('#workload_table').fixedHeaderTable({ height: String(h), footer: false, fixedColumn: false });
  //$j('#workload_qs_spider_table').fixedHeaderTable({ height: '500', footer: false, fixedColumn: false });
  return h;
  }

function display_milestones(evt,text) {
  var popup = $('milestones')
  var e = evt;
  popup.style.top  = e.clientY + "px";
  popup.style.left = e.clientX + "px";
  popup.innerHTML = text;
  popup.show();
}
function hide_milestones(text) {
  $('milestones').hide();
  }

function wl_save_value(line_id, wlweek, view_by) {
  new Ajax.Request('/workloads/edit_load?l='+line_id+'&w='+wlweek+'&v='+$(line_id+'_'+wlweek).value+'&view_by='+view_by, {
    asynchronous:true,
    evalScripts:true
    });
  }

lines_hlighted = new Hash;
function highlight_wl_line(id, color) {
  el = $('wl_line_'+id);
  if(!lines_hlighted[id]) {
    lines_hlighted[id] = [0,el.style.backgroundColor];
    }
  if(lines_hlighted[id][0] == 1) {
    el.style.backgroundColor  = lines_hlighted[id][1];
    lines_hlighted[id][0] = 0;
    }
  else {
    el.style.backgroundColor  = color;
    lines_hlighted[id][0] = 1;
    }
  }
function check_uncheck(source,name) {
  var checkboxes = document.getElementsByName(name);
  var nb_checked = 0;
  for(var i=0, n=checkboxes.length;i<n;i++) {
    if (checkboxes[i].checked == true) {nb_checked=nb_checked+1;}
  }
  if (nb_checked<checkboxes.length) {
    for(var i=0, n=checkboxes.length;i<n;i++) {
      checkboxes[i].checked = true;
    }
  }else{
    for(var i=0, n=checkboxes.length;i<n;i++) {
      checkboxes[i].checked = false;
    }
  }
}
function check_uncheck_iterations(source,id) {
  var checkboxes = $$('#'+id);
  var nb_checked = 0;
  for(var i=0, n=checkboxes.length;i<n;i++) {
    if (checkboxes[i].checked == true) {nb_checked=nb_checked+1;}
  }
  if (nb_checked<checkboxes.length) {
    for(var i=0, n=checkboxes.length;i<n;i++) {
      checkboxes[i].checked = true;
    }
  }else{
    for(var i=0, n=checkboxes.length;i<n;i++) {
      checkboxes[i].checked = false;
    }
  }
}
function change_task_color(source,id) {
  var task_cells = $$('#'+id);
  var color_cell = $('color_'+id);
  for(var i=0, n=task_cells.length;i<n;i++) {
    task_cells[i].style.backgroundColor  = color_cell.style.backgroundColor;
  }
  new Ajax.Request('/project_workloads/update_color_task', {
    parameters: { id: id[id.length-1], color: colorToHex(color_cell.style.backgroundColor)  }
  });
}

function colorToHex(color) {
    if (color.substr(0, 1) === '#') {
        return color;
    }
    var digits = /(.*?)rgb\((\d+), (\d+), (\d+)\)/.exec(color);
    
    var red = parseInt(digits[2]);
    var green = parseInt(digits[3]);
    var blue = parseInt(digits[4]);
    
    var rgb = blue | (green << 8) | (red << 16);
    return digits[1] + '#' + rgb.toString(16);
};

function addTag(last_tag, line_id){
  new Ajax.Request('/tags/add_tag', {
    parameters: { tag_name: last_tag, line_id: line_id }
  });
}

function removeTag(tags, line_id){
  new Ajax.Request('/tags/remove_tag', {
    parameters: { tags: String(tags), line_id: line_id }
  });
}

function init_tags(line_id, sampleTags) {
  $j("#lineTags_"+line_id).tagit({
    availableTags: sampleTags,
    removeConfirmation: true,
    caseSensitive: false,
    afterTagAdded: function(event, ui) {
      a = $j('#lineTags_'+line_id).tagit('assignedTags');
      addTag(a[a.length -1],line_id);
    },
    afterTagRemoved: function(event, ui) {
      a = $j('#lineTags_'+line_id).tagit('assignedTags');
      removeTag(a,line_id);
    }
  });
}
