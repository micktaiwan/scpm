// TODO: rendre plus visuel les dates de début et fin de tâches
// TODO: the last day of tasks shall be working days 
Date.prototype.addDays = function(days) {
  this.setDate(this.getDate()+days);
  };

Date.prototype.diffInDays = function(d2) {
  var t1 = this.getTime();
  var t2 = d2.getTime();
  return Math.ceil((t2-t1)/(24*3600*1000));
  };

var Task = Class.create ({
  initialize: function(planning, task) {
    this.planning         = planning;
    this.name             = task.name
    this.start_date       = new Date(task.start_date);
    this.end_date         = new Date(task.end_date)
    this.work_in_day      = task.work_in_day;
    this.vertTitleSpacing = 12;
    this.taskHeight       = this.planning.taskHeight-2;
    this.leftCoords       = {x: null, y: null} // top left
    this.rightCoords      = {x: null, y: null} // bottom right
    this.titleColor       = 'blue';
    this.setMouseOutShape();
    },

  draw: function (y) {
    this.planning.ctx.fillStyle   = this.titleColor;
    this.planning.ctx.fillText(this.name, 2, y + this.planning.dateHeaderHeight + this.vertTitleSpacing);
    //this.drawTitle(y);
    x         = this.planning.getTaskX(this);
    limRight  = this.planning.canvas.width -this.planning.canvasEndBorder;
    if(x > limRight) // out of the canvas
      return;
    lim       = this.planning.taskTitleWidth
    length    = (this.start_date.diffInDays(this.end_date)) * this.planning.pixelsForOneDay;
    if(x+length < lim) return; // out of the canvas
    if(x < lim) {
      length -= lim-x; // reduce length
      x = lim; // do not draw the start of the task that is out of the left limit
      }
    if(x+length > limRight) // do not draw the rest of the task that is out the canvas (on the right)
      length -= (x+length - limRight)
    // save the coordinates (to be able to get the tasks under the click, for example)
    this.leftCoords.x  = x;
    this.leftCoords.y  = y + this.planning.dateHeaderHeight;
    this.rightCoords.x = x + length;
    this.rightCoords.y = y + this.planning.dateHeaderHeight + this.taskHeight;

    this.planning.ctx.fillStyle   = this.color;
    this.planning.ctx.fillRect(x, y + this.planning.dateHeaderHeight, length, this.taskHeight);
    },

  drawTitle: function(y) {
    // var input   = document.createElement("input");
    // input.top   = y;
    // input.value = this.name;
    },

  reactToMouseOver: function(coords, alreadyIn) {
    if(coords.x < this.leftCoords.x || coords.x > this.rightCoords.x || coords.y < this.leftCoords.y || coords.y > this.rightCoords.y) {
      this.setMouseOutShape(alreadyIn);
      return false;
      }
    else {
      if(coords.x > this.rightCoords.x - 10)
        this.setMouseEndTaskShape();
      else
        this.setMouseInShape();
      return true;
      }
    },

  setMouseInShape: function() {
    this.color = "rgba(50, 50, 200, 1.0)";
    document.body.style.cursor = 'default';
    },

  setMouseEndTaskShape: function() {
    this.color = "rgba(200, 0, 200, 1.0)";
    document.body.style.cursor = 'e-resize';
    },

  setMouseOutShape: function(alreadyIn) {
    this.color = "rgba(100, 100, 255, 0.9)";
    if(!alreadyIn) document.body.style.cursor = 'default';
    }
});



//=============================================================================
//=============================================================================
//=============================================================================

var Planning = Class.create({
  initialize: function(canvas_id, tasks, teamSize) {
    // initialize defaults, etc.
    window.Planning          = this; // define this class global, so it is accessible from event handlers
    this.canvas_id           = canvas_id || "planning_canvas";
    this.canvas              = $(this.canvas_id);
    this.canvas.width        = window.screen.width - this.canvas.offsetLeft - 20;
    this.canvas.height       = 400;
    this.ctx                 = this.canvas.getContext("2d");
    this.teamSize            = teamSize || new Array(10);
    this.taskTitleWidth      = 150;
    this.tasksHeight         = 250;
    this.teamHeight          = this.canvas.height - this.tasksHeight;
    this.dateHeaderHeight    = 30;
    this.tasksHeightAbsolute = this.dateHeaderHeight + this.tasksHeight - 0.5;
    this.canvasEndBorder     = 25;
    this.taskBarMaxWidth     = this.canvas.width - this.taskTitleWidth - this.canvasEndBorder
    this.start_date          = new Date();
    this.start_date.addDays(-10);
    this.setPlanningWidthInDay(60);
    this.months              = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    this.mouseCoords         = null; // current mouse coords
    this.fromCoords          = null; // down event ouse coords
    this.mouseOverCoords     = null; // every time the mouse moves
    this.mouseState          = null;
    this.taskHeight          = 20;
    this.weekendColor        = 'gray';
    this.todayColor          = 'yellow';
    this.teamSizeColor       = 'blue';
    HTMLCanvasElement.prototype.relMouseCoords = this.relMouseCoords;

    // tasks
    this.tasks = new Array();
    for(var i=0; i < tasks.length; i++) {
      this.tasks.push(new Task(this, tasks[i].task));
      }

    // Draw the grid
    this.draw();

    // listen to mouse
    this.canvas.addEventListener("mousedown", this.onMouseDown, false);
    this.canvas.addEventListener("mouseup",   this.onMouseUp, false);
    this.canvas.addEventListener("mousemove", this.onMouseMove, false);
    this.canvas.addEventListener("mouseout",  this.onMouseOut, false);
    },

  setPlanningWidthInDay: function(days) {
    if(days < 15 || days > 120) return;
    this.planningWidthInDay = days;
    this.end_date           = new Date(this.start_date.valueOf());
    this.end_date.addDays(this.planningWidthInDay);
    },

  setDrawingVariables: function() {
    this.taskTitleWidth   = this.getMaxTitleLength() + 5; // recalculate task titles width function of the max title length
    this.taskBarMaxWidth  = this.canvas.width - this.taskTitleWidth - this.canvasEndBorder
    this.pixelsForOneDay  = this.taskBarMaxWidth / this.planningWidthInDay;
    },

  draw: function() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    this.ctx.fillStyle    = "rgba(100, 100, 255, 1.0)";
    this.ctx.font         = "12px Helvetica";
    this.ctx.lineWidth    = 1;
    this.setDrawingVariables();
    this.drawGrid();
    for(var i=0; i < this.tasks.length; i++) {
      this.tasks[i].draw(1+i*this.taskHeight);
      }
    this.drawTeamSize();
    },
  
  getMaxTitleLength: function() {
    var len, max = 0;
    for(var i=0; i < this.tasks.length; i++) {
      len = this.ctx.measureText(this.tasks[i].name).width;
      if(max < len) max = len;
      }
    return max;
    },

  drawGrid: function() {
    var current_date = new Date(this.start_date);
    var today        = new Date();
    current_date.setHours(0,0,0,0);
    today.setHours(0,0,0,0);
    this.drawDateHeader();
    // top horizontal line
    this.drawLine(0,this.dateHeaderHeight-0.5, this.canvas.width-this.canvasEndBorder, this.dateHeaderHeight-0.5)
    // tasks bottom horizontal line
    this.drawLine(0,this.tasksHeightAbsolute, this.canvas.width-this.canvasEndBorder, this.tasksHeightAbsolute)
    // bottom horizontal line
    this.drawLine(0,this.canvas.height-0.5, this.canvas.width-this.canvasEndBorder, this.canvas.height-0.5)
    // vertical lines for days
    this.ctx.strokeStyle = "black";
    for(var i=0; i <= this.planningWidthInDay; i++) {
      this.drawLine(this.taskTitleWidth+i*this.pixelsForOneDay-0.5,this.dateHeaderHeight, this.taskTitleWidth+i*this.pixelsForOneDay-0.5,this.tasksHeightAbsolute)
      var current_day = current_date.getDay();
      // drawing week-ends
      if(current_day==6 || current_day==0) {
        this.ctx.fillStyle   = this.weekendColor;
        this.ctx.fillRect(this.taskTitleWidth+i*this.pixelsForOneDay-0.5, this.dateHeaderHeight, this.pixelsForOneDay, this.tasksHeight-1);
        }
      // drawing today
      if(current_date.getTime()==today.getTime()) {
        this.ctx.fillStyle   = this.todayColor;
        this.ctx.fillRect(this.taskTitleWidth+i*this.pixelsForOneDay-0.5, this.dateHeaderHeight, this.pixelsForOneDay, this.tasksHeight-1);
        }
      current_date.addDays(1);
      }
    // mouse position
    if(this.mouseOverCoords) {
      x = this.mouseOverCoords.x-0.5
      if(x > this.taskTitleWidth && x < (this.canvas.width - this.canvasEndBorder)) {
        this.ctx.strokeStyle = "black";
        this.drawLine(x,this.dateHeaderHeight-10, x, this.canvas.height-0.5)
        date = this.getDateForX(x);
        if(date)
          this.ctx.fillText(this.myDateFormat(date), x-15, 20);
        }
      }
    },

  drawDateHeader: function() {
    this.ctx.fillText(this.myDateFormat(this.start_date), this.taskTitleWidth-15, 20);
    this.ctx.fillText(this.myDateFormat(this.end_date), this.canvas.width-this.canvasEndBorder - 15, 20);
    },

  drawTeamSize: function() {
    // vertical lines for each day
    this.ctx.fillStyle = this.teamSizeColor;
    var date = new Date(this.start_date);
    date.setHours(0,0,0,0);
    current_nb = 0;
    max_nb = this.getMaxTeamHeight();
    var pixelsForOnePerson = (this.teamHeight - 35) / max_nb;
    var nb;
    for(var i=0; i <= this.planningWidthInDay; i++) {
      date_str = date.getFullYear() + "-" + this.padStr(date.getMonth()+1) + "-" + this.padStr(date.getDate());
      nb = this.getTeamSize(date_str);
      x  = this.taskTitleWidth + i*this.pixelsForOneDay;
      if(current_nb!=nb) {
          current_nb = nb;
          this.ctx.fillText(current_nb, x, this.canvas.height-5);
          }
      height   = this.canvas.height - nb * pixelsForOnePerson;
      if(nb > 0) {
        this.ctx.fillRect(x, height, this.pixelsForOneDay+0.5, this.canvas.height-height-20);
        }
      date.addDays(1);
      }
    },
    
    // get the maximum  heigth for a day
    getMaxTeamHeight: function() {
      var date, nb, nb, max=0;
      date = new Date(this.start_date);
      date.setHours(0,0,0,0);
      for(var i=0; i <= this.planningWidthInDay; i++) {
        date_str = date.getFullYear() + "-" + this.padStr(date.getMonth()+1) + "-" + this.padStr(date.getDate());
        nb   = this.getTeamSize(date_str);
        if(max < nb) max = nb;
        date.addDays(1);
        }
      return max;
      },

  padStr: function(i) {
    return (i < 10) ? "0" + i : "" + i;
    },

  getTeamSize: function(date) {
    //window.console.log(date);
    for(i=0; i < this.teamSize.length; i++) {
      //window.console.log(this.teamSize[i])
      if(this.teamSize[i][0] == date)
        return this.teamSize[i][1];
      }
    return 0;
    },

  myDateFormat: function(date) {
    return date.getDate() + '-' + this.months[date.getMonth()];
    },

  onMouseDown: function(event) {
    window.Planning.fromCoords  = this.relMouseCoords(event);
    window.Planning.mouseState  = 'down';
    },

  onMouseUp: function(event) {
    window.Planning.mouseCoords = this.relMouseCoords(event);
    window.Planning.mouseState  = 'up';
    },

  onMouseOut: function(event) {
    window.Planning.mouseState  = 'up';
    },

  mouseOver: function(coords) {
    // tasks mouseover
    alreadyIn = false;
    for(var i=0; i < this.tasks.length; i++) {
      alreadyIn = this.tasks[i].reactToMouseOver(coords, alreadyIn) || alreadyIn;
      }
    // overall planning mouseover
    // TODO: this.mouseoverDate =
    this.draw();
    },

  onMouseMove: function(event) {
    window.Planning.mouseOverCoords  = this.relMouseCoords(event);
    if(window.Planning.mouseState!='down') {
      window.Planning.mouseOver(this.relMouseCoords(event));
      return;
      }
    moved = false;

    window.Planning.mouseCoords = this.relMouseCoords(event);
    delta = (window.Planning.fromCoords.x - window.Planning.mouseCoords.x)*1.1 / window.Planning.pixelsForOneDay;
    if(Math.abs(delta) >= 1) {
      // tasks translation (horizontal move)
      if(delta < 0) delta = Math.ceil(delta);
      else          delta = Math.floor(delta);
      window.Planning.start_date.addDays(delta);
      window.Planning.end_date.addDays(delta);
      moved = true;
      }
    else {
      // zoom (vertical move)
      delta = (window.Planning.mouseCoords.y - window.Planning.fromCoords.y) / 3;
      if(Math.abs(delta) >= 1) {
        window.Planning.setPlanningWidthInDay(window.Planning.planningWidthInDay+delta);
        moved = true;
        }
      }
    if(moved) {
      window.Planning.fromCoords = this.relMouseCoords(event);
      window.Planning.draw();
      }
    },

  relMouseCoords: function (e){
    var cx;
    var cy;
    if (e.pageX || e.pageY) {
      cx = e.pageX;
      cy = e.pageY;
      }
    else {
      cx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
      cy = e.clientY + document.body.scrollTop  + document.documentElement.scrollTop;
    }
    cx -= this.offsetLeft;
    cy -= this.offsetTop;
    return {x:cx, y:cy}
  },

  // given a task, return the absolute task abscissa (in pixels)
  getTaskX: function(task) {
    days_in_pixels = (this.start_date.diffInDays(task.start_date)) * this.pixelsForOneDay;
    return this.taskTitleWidth + days_in_pixels;
    },

  // given a abcissa, return the day
  getDateForX: function(x) {
    if(x < this.taskTitleWidth)
      return null;
    date = new Date(this.start_date)
    date.addDays(Math.floor(((x-this.taskTitleWidth) / this.pixelsForOneDay)));
    return date;
    },

  drawLine: function(x,y,a,b) {
    this.ctx.beginPath();
    this.ctx.moveTo(x,y);
    this.ctx.lineTo(a,b);
    this.ctx.stroke();
    }

});
