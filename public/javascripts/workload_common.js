function wl_add_line() {
  $('wl_line_add_form').appear({duration:0.2});
  }

function wl_change_colors(wlweek, background, color) {
  $('cpercent_'+wlweek).style.background  = background;
  $('cpercent_'+wlweek).style.color       = color;
  }

function set_fixed_header() {
  $j('#workload_table').fixedHeaderTable({ height: '500', footer: false, fixedColumn: false });
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
