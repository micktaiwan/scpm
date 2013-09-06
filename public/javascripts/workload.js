function hide_lines_with_no_workload() {
  document.body.style.cursor = 'wait';
  $('loading').show();
  new Ajax.Request('/workloads/hide_lines_with_no_workload', {
    parameters: { on: $('hide_lines_with_no_workload').checked }
    });
}

function update_settings_name(){
  var checkbox = $('update_sdp_tasks_name');
  // window.checkout_status = checkbox[0].checked==true;
    new Ajax.Request('/workloads/update_settings_name', {
    parameters: { on: checkbox.checked==true }
    });
}

function hide_workload_menu() {
  $('wmenu').toggle();
  new Ajax.Request('/workloads/hide_wmenu', {
    parameters: { on: $('wmenu').style.display=='none' }
    });
}
function get_all_sdp_tasks() {
  new Ajax.Updater("sdp_task_id", "/workloads/do_get_sdp_tasks");  
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

function change_workload(person_id) {
  document.body.style.cursor = 'wait';
  $('loading').show();
  new Ajax.Request('/workloads/change_workload', {
    parameters: { person_id: person_id }
    });
  }
function wl_edit(line_id) {
  new Ajax.Request('/workloads/display_edit_line?l='+line_id, {
    asynchronous:true,
    evalScripts:true,
    onComplete: function(r) {new Draggable($('edit_line'));}
    });
}
