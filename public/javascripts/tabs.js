/*-----------------------------------------------------------
    Toggles element's display value
    Input: any number of element id's
    Output: none
    ---------------------------------------------------------*/
function toggleDisp() {
    for (var i=0;i<arguments.length;i++){
        var d = $(arguments[i]);
        if (d.style.display == 'none')
            d.style.display = 'block';
        else
            d.style.display = 'none';
    }
}
/*-----------------------------------------------------------
    Toggles tabs - Closes any open tabs, and then opens current tab
    Input:     1.The number of the current tab
                    2.The number of tabs
                    3.(optional)The number of the tab to leave open
                    4.(optional)Pass in true or false whether or not to animate the open/close of the tabs
    Output: none
    ---------------------------------------------------------*/
function toggleTab(name, num,numelems,opennum,animate) {
    if ($('tabContent'+num).style.display == 'none'){
        createCookie("tab_menu_"+name,num);
        for (var i=1;i<=numelems;i++){
            if ((opennum == null) || (opennum != i)){
                var temph = 'tabHeader'+i;
                var h = $(temph);
                if (!h){
                    var h = $('tabHeaderActive');
                    h.id = temph;
                }
                var tempc = 'tabContent'+i;
                var c = $(tempc);
                if(c.style.display != 'none'){
                    if (animate || typeof animate == 'undefined')
                        Effect.toggle(tempc,'slide',{duration:0.1, queue:{scope:'menus', limit: 3}});
                    else
                        toggleDisp(tempc);
                }
            }
        }
        var h = $('tabHeader'+num);
        if (h)
            h.id = 'tabHeaderActive';
        h.blur();
        var c = $('tabContent'+num);
        c.style.marginTop = '2px';
        if (animate || typeof animate == 'undefined'){
            Effect.toggle('tabContent'+num,'appear',{duration:0.5, queue:{scope:'menus', position:'end', limit: 3}});
        }else{
            toggleDisp('tabContent'+num);
        }
    }
}

// A virer ?
function load_contents() {
  new Ajax.Updater('conso_workloads', '/workloads/conso_workloads', {
    asynchronous:true,
    evalScripts:true
    });
  }

document.observe("dom:loaded", function() {
  //load_contents();
});
