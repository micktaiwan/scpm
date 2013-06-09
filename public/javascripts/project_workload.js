function hide_lines_with_no_workload() {
  document.body.style.cursor = 'wait';
  $('loading').show();
  new Ajax.Request('/project_workloads/hide_lines_with_no_workload', {
    parameters: { on: $('hide_lines_with_no_workload').checked }
    });
}

function hide_workload_menu() {
  $('wmenu').toggle();
  new Ajax.Request('/project_workloads/hide_wmenu', {
    parameters: { on: $('wmenu').style.display=='none' }
    });
}

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

function wl_save_value(line_id, wlweek) {
  new Ajax.Request('/workloads/edit_load?l='+line_id+'&w='+wlweek+'&v='+$(line_id+'_'+wlweek).value, {
    asynchronous:true,
    evalScripts:true
    });
  }

function wl_edit(line_id) {
  new Ajax.Request('/project_workloads/display_edit_line?l='+line_id, {
    asynchronous:true,
    evalScripts:true,
    onComplete: function(r) {new Draggable($('edit_line'));}
    });
}

function change_workload(project_id) {
  document.body.style.cursor = 'wait';
  $('loading').show();
  new Ajax.Request('/project_workloads/change_workload', {
    parameters: { project_id: project_id }
    });
  }
