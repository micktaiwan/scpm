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


// Duplicate

function check_duplicate_workload_interactions()
{
  $$(".duplicate_load_td").invoke('observe', 'click', function(){
    if (this.select("input")[0].checked == true)
    {
      this.select("input")[0].checked=false;
      this.setStyle({
          backgroundColor: "white"
      });
    }
    else
    {
      this.select("input")[0].checked=true;
      this.setStyle({
          backgroundColor: "#FF9BAB"
      });
    }
  });

}

// backup functions

var selected_backup_person_id = null;
var selected_backup_date = null;
function check_backup_person_change()
{  
  Event.observe($('select_list_backup_person'), 'change', function()
  {
      selected_backup_person_id = $('select_list_backup_person').getValue();
  });
}

function add_backup_action()
{
  $("view_backup_add").show();
}

function update_selected_backup_date()
{
  selected_backup_date = $("select_list_year").value+""+$("select_list_week").value;
}

function add_backup(person_id, backup_person_id, week)
{

  if (week != null)
  {
    // Call the controller/action in ajax
    new Ajax.Request('/workloads/create_backup', 
    {
      parameters: { backup_person_id: backup_person_id, person_id: person_id, week: week },
      onSuccess: function(response) 
      {
          if ( (response.responseText != null) && (response.responseText.length > 1))
          {
             var date = "";
             var name = "";
             var responseArray = response.responseText.split('_');
             if (responseArray.length == 2)
             {
               date = responseArray[0];
               name = responseArray[1];
             }

             $("backup_list").innerHTML += "<tr><td>" + date.substring(4,6) + "-" + date.substring(0,4) + "</td><td>" + name + "</td><td></td></tr>";
          }
          $("view_backup_add").hide();
      },
      onFailure:function(response) 
      {
        alert("Error: Can't add the person has backup.")
        $("view_backup_add").hide();
      }
    });
  }
  else
  {
    alert("Please, select a date.");
  }
}

function delete_wl_backup(backup_id, self_backup)
{
  new Ajax.Request('/workloads/delete_backup', 
  {
    parameters: { backup_id: backup_id},
    onSuccess: function(response) 
    {
        if (self_backup)
          $("self_backup_"+backup_id).hide();
        else
          $("backup_"+backup_id).hide();
    },
    onFailure:function(response) 
    {
      alert("Error: Can't delete the backup.")
    }
  });
}

function update_backup_comment(backup_id, self_backup)
{
  var comment = null;
  if (self_backup)
    comment = $('self_backup_comment_'+backup_id).value;
  else 
    comment = $('backup_comment_'+backup_id).value;
  new Ajax.Request('/workloads/update_backup_comment', 
  {
    parameters: { backup_id: backup_id, backup_comment: comment},
    onSuccess: function(response) 
    {
      if ( (response.responseText != null) && (response.responseText.length > 0))
        if (self_backup)
          $('self_backup_comment_'+backup_id).innerHTML = response.responseText
        else
          $('backup_comment_'+backup_id).innerHTML = response.responseText
    },
    onFailure:function(response) 
    {
      alert("Error: Can't update the backup.")
    }
  });
}