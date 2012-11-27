Date.prototype.addDays = function(days) {
  this.setDate(this.getDate()+days);
  };

Date.prototype.diffInDays = function(d2) {
  var t2 = d2.getTime();
  var t1 = this.getTime();
  return parseInt((t2-t1)/(24*3600*1000));
  };

var Task = Class.create ({
  initialize: function(planning, task) {
    this.planning         = planning;
    this.name             = task.name
    this.start_date       = new Date(task.start_date);
    this.duration         = task.duration_in_day;
    this.vertTitleSpacing = 12;
    },

  draw: function (y) {
    this.planning.ctx.fillText(this.name, 2, y + this.planning.dateHeaderHeight + this.vertTitleSpacing);
    x = this.planning.getTaskX(this);
    limRight =  this.planning.canvas.width -this.planning.canvasEndBorder;
    if(x > limRight)
      return;
    lim    = this.planning.taskTitleWidth
    length = this.duration*this.planning.pixelsForOneDay;
    if(x+length < lim) return;
    if(x < lim) {
      length -= lim-x;
      x = lim;
      }
    if(x+length > limRight)
      length -= (x+length - limRight)
    this.planning.ctx.fillRect(x, y + this.planning.dateHeaderHeight, length, 18);
    }
});

var Planning = Class.create({
  initialize: function(canvas_id,tasks) {
    // Actually start initializing defaults etc.
    window.Planning         = this; // define this class global, so it is accessible from event handlers
    this.canvas_id          = canvas_id || "planning";
    this.canvas             = $(this.canvas_id);
    this.ctx                = this.canvas.getContext("2d");
    this.taskTitleWidth     = 150;
    this.canvasEndBorder    = 25;
    this.taskBarMaxWidth    = this.canvas.width - this.taskTitleWidth - this.canvasEndBorder
    this.dateHeaderHeight   = 30;
    this.start_date         = new Date();
    this.end_date           = new Date(this.start_date.valueOf());
    this.planningWidthInDay = 60;
    this.end_date.addDays(this.planningWidthInDay);
    this.pixelsForOneDay    = this.taskBarMaxWidth / this.planningWidthInDay;
    this.months             = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    this.mouseCoords        = null; // current mouse coords
    this.fromCoords         = null; // down event ouse coords
    this.mouseState         = null;
    HTMLCanvasElement.prototype.relMouseCoords = this.relMouseCoords;

    // tasks
    this.tasks = new Array();
    for(var i=0; i < tasks.length; i++) {
      this.tasks.push(new Task(this, tasks[i].task));
      }

    // Draw the grid
    this.draw();

    // listen to the mouse clicks
    this.canvas.addEventListener("mousedown", this.onMouseDown, false);
    this.canvas.addEventListener("mouseup",   this.onMouseUp, false);
    this.canvas.addEventListener("mousemove", this.onMouseMove, false);
    },

  draw: function() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    this.ctx.fillStyle   = "rgba(100, 100, 255, 1.0)";
    this.ctx.font        = "12px Helvetica";
    this.ctx.lineWidth   = 1;
    this.ctx.strokeStyle = "black";
    this.drawGrid();
    for(var i=0; i < this.tasks.length; i++) {
      this.tasks[i].draw(1+i*20);
      }
    },

  drawGrid: function() {
    this.drawDateHeader();
    this.ctx.beginPath();
    this.ctx.moveTo(0,this.dateHeaderHeight-0.5);
    this.ctx.lineTo(this.canvas.width-this.canvasEndBorder, this.dateHeaderHeight-0.5);
    this.ctx.stroke();
    this.ctx.beginPath();
    this.ctx.moveTo(0,this.canvas.height-0.5);
    this.ctx.lineTo(this.canvas.width-this.canvasEndBorder, this.canvas.height-0.5);
    this.ctx.stroke();
    for(var i=0; i <= this.planningWidthInDay; i++) {
      this.ctx.beginPath();
      this.ctx.moveTo(this.taskTitleWidth+i*this.pixelsForOneDay-0.5,this.dateHeaderHeight);
      this.ctx.lineTo(this.taskTitleWidth+i*this.pixelsForOneDay-0.5,this.canvas.height);
      this.ctx.stroke();
      }
    },

  drawDateHeader: function() {
    this.ctx.fillText(this.myDateFormat(this.start_date), this.taskTitleWidth-15, 20);
    this.ctx.fillText(this.myDateFormat(this.end_date), this.canvas.width-this.canvasEndBorder - 15, 20);
    },

  myDateFormat: function(date) {
    return date.getDate() + '-' + this.months[date.getMonth()];
    },

  onMouseDown: function(event) {
    window.Planning.fromCoords = this.relMouseCoords(event);
    window.Planning.mouseState = 'down';
    },
  onMouseUp: function(event) {
    window.Planning.mouseCoords = this.relMouseCoords(event);
    window.Planning.mouseState = 'up';
    },
  onMouseMove: function(event) {
    if(window.Planning.mouseState!='down') return;
    window.Planning.mouseCoords = this.relMouseCoords(event);
    delta = -(window.Planning.mouseCoords.x - window.Planning.fromCoords.x) / window.Planning.pixelsForOneDay;
    if(Math.abs(delta) < 1) return;
    window.Planning.start_date.addDays(delta);
    window.Planning.end_date.addDays(delta);
    window.Planning.fromCoords = this.relMouseCoords(event);
    window.Planning.draw();
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
    days = this.start_date.diffInDays(task.start_date) * this.pixelsForOneDay;
    return this.taskTitleWidth + days;
    }

});
