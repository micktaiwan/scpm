// Copy selected element
function selectElementContents(el){
  var body = document.body, range, sel;

  if (document.createRange && window.getSelection) {
    range = document.createRange();
    sel = window.getSelection();
    sel.removeAllRanges();
    try {
      range.selectNodeContents(el);
      sel.addRange(range);
    } catch (e) {
      range.selectNode(el);
      sel.addRange(range);
    }
  } else if (body.createTextRange) {
    range = body.createTextRange();
    range.moveToElementText(el);
    range.select();
  }
}

// Copy el html in copy table. Show the copy view
function copyInView(el)
{
   var top = window.pageYOffset || document.documentElement.scrollTop
   $j("#copy_view").css({ top: top+100 });
   $j("#copy_table").html(el.html());
   $j("#copy_view").show();
   selectElementContents(document.getElementById("copy_table"));
  
   // Remove hyper link
   var elements = $j("#copy_view a");
   for (var i = 0; i < elements.length; i++) {
     elements[i].href = "javascript:void(0)";
   };

   // Remove admin
   $j.each($j("#copy_view .admin"), function(){
    $j(this).remove();
   });
}
