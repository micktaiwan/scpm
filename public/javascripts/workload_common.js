function wl_add_line() {
  $('wl_line_add_form').appear({duration:0.2});
  }

function wl_change_colors(wlweek, background, color) {
  $('cpercent_'+wlweek).style.background  = background;
  $('cpercent_'+wlweek).style.color       = color;
  }
function wl_case_change_colors(line, wlweek, background, color) {
  $(line + '_' + wlweek).style.background  = background;
  $(line + '_' + wlweek).style.color       = color;
  }

function set_fixed_header() {
  $j('#workload_table').fixedHeaderTable({ height: String($('workload_table').getElementsByTagName("tr").length*22), footer: false, fixedColumn: false });
  //$j('#workload_qs_spider_table').fixedHeaderTable({ height: '500', footer: false, fixedColumn: false });
  }

function display_milestones(evt,text) {
  var popup = $('milestones')
  var e = evt;
  popup.style.top  = e.clientY + "px";
  popup.style.left = e.clientX + "px";
  // popup.style.top = parseInt(Event.pointerY(e))+"px"
  // popup.style.left = parseInt(Event.pointerX(e))+"px"
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

function highlight_wl_line(id, color) {
  $('wl_line_'+id).style.background  = color;
}
