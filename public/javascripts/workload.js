Ajax.Replacer = Class.create(Ajax.Updater, {
  initialize: function($super, container, url, options) {
    options = options || { };
    options.onComplete = (options.onComplete || Prototype.emptyFunction)
      .wrap(function(proceed, transport, json) {
        $(container).replace(transport.responseText);
        proceed(transport, json);
      })
    $super(container, url, options);
  }
})

function wl_add_line(person_id) {
  $('wl_line_add_form').appear({duration:0.2});
  }

function wl_save_value(line_id, wlweek) {
  new Ajax.Request('/workloads/edit_load?l='+line_id+'&w='+wlweek+'&v='+$(line_id+'_'+wlweek).value, {
    asynchronous:true,
    evalScripts:true
    });
  }

function wl_edit(line_id) {
  new Ajax.Request('/workloads/display_edit_line?l='+line_id, {
    asynchronous:true,
    evalScripts:true
    });
}

function wl_change_colors(wlweek, background, color) {
  $('cpercent_'+wlweek).style.background  = background;
  $('cpercent_'+wlweek).style.color       = color;
  }

function change_workload(person_id) {
  document.body.style.cursor = 'wait';
  $('loading').show();
  new Ajax.Request('/workloads/change_workload', {
    parameters: { person_id: person_id }
    });
  }

function set_fixed_header() {
  $j('#workload_table').fixedHeaderTable({ height: '600', footer: false, fixedColumn: false });
  }

function display_milestones(text) {
  popup = $('milestones')
  e = window.event;
  popup.style.top = (parseInt(Event.pointerY(e))-80)+"px"
  popup.style.left = (parseInt(Event.pointerX(e))-220)+"px"
  popup.innerHTML = text;
  popup.show();
  }
function hide_milestones(text) {
  $('milestones').hide();
  }

