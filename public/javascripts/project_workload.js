function hide_lines_with_no_workload() {
  document.body.style.cursor = 'wait';
  $('loading').show();
  new Ajax.Request('/project_workloads/hide_lines_with_no_workload', {
    parameters: { on: $('hide_lines_with_no_workload').checked }
    });
}
function check(source) {
var checkboxes = document.getElementsByName('companies_ids[]');
  for(var i=0, n=checkboxes.length;i<n;i++) {
    checkboxes[i].checked = true;
  }
}
function uncheck(source) {
var checkboxes = document.getElementsByName('companies_ids[]');
  for(var i=0, n=checkboxes.length;i<n;i++) {
    checkboxes[i].checked = false;
  }
}
function verify_filter(source) {
  var companies     = document.getElementsByName('companies_ids[]');
  var projects      = document.getElementsByName('project_ids[]');
  var nb_companies  = 0; 
  var nb_projects   = 0;
  for(var i=0, n=companies.length;i<n;i++) {
    if (companies[i].checked == true) {nb_companies = nb_companies+1;}
  }
  for(var i=0, n=projects.length;i<n;i++) {
    if (projects[i].checked == true) {nb_projects = nb_projects+1;}
  }
  if ((nb_projects==0)||(nb_companies==0)) {alert('At least, one project and one company should be selected to continue!'); return false;}
  else {
      document.forms["filter_projects_companies"].submit();
      // alert(f);
    //  .submit();
    }
}

function group_by_person() {
  document.body.style.cursor = 'wait';
  $('loading').show();
  new Ajax.Request('/project_workloads/group_by_person', {
    parameters: { on: $('group_by_person').checked }
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

function change_workload(project_ids) {
  document.body.style.cursor = 'wait';
  $('loading').show();
  new Ajax.Request('/project_workloads/change_workload', {
    parameters: { project_ids: project_ids }
    });
  }
