Date.prototype.addDays = function(days) {
  this.setDate(this.getDate()+days);
  }

var Task = Class.create ({
  initialize: function(planning, task) {
    this.planning    = planning;
    this.name        = task.name
    this.start_date  = new Date(task.start_date);
    this.duration    = task.duration_in_day;
    this.vertTitleSpacing = 12;
    },

  draw: function (y) {
    this.planning.ctx.fillText(this.name, 2, y + this.planning.dateHeaderHeight + this.vertTitleSpacing);
    this.planning.ctx.fillRect(this.planning.taskTitleWidth, y + this.planning.dateHeaderHeight, this.duration, 18);
    }
});

var Planning = Class.create({
  initialize: function(canvas_id,tasks) {
    // Actually start initializing defaults etc.
    this.canvas_id          = canvas_id || "planning";
    this.canvas             = $(this.canvas_id);
    this.ctx                = this.canvas.getContext("2d");
    this.taskTitleWidth     = 150;
    this.canvasEndBorder    = 25;
    this.taskBarMaxWidth    = this.canvas.width - this.taskTitleWidth - this.canvasEndBorder
    this.dateHeaderHeight   = 30;
    this.start_date         = new Date();
    this.end_date           = new Date(this.start_date.valueOf());
    this.planningWidthInDay = 15
    this.end_date.addDays(this.planningWidthInDay);
    this.vertLinesSpacing   = this.taskBarMaxWidth / this.planningWidthInDay;
    this.months             = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']


    // tasks
    this.tasks = new Array();
    for(var i=0; i < tasks.length; i++) {
      this.tasks.push(new Task(this, tasks[i].task));
      }

    // Draw the grid
    this.draw();
    },

  draw: function() {
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
      this.ctx.moveTo(this.taskTitleWidth+i*this.vertLinesSpacing-0.5,this.dateHeaderHeight);
      this.ctx.lineTo(this.taskTitleWidth+i*this.vertLinesSpacing-0.5,this.canvas.height);
      this.ctx.stroke();
      }
    },

  drawDateHeader: function() {
    this.ctx.fillText(this.myDateFormat(this.start_date), this.taskTitleWidth-15, 20);
    this.ctx.fillText(this.myDateFormat(this.end_date), this.canvas.width-this.canvasEndBorder - 15, 20);
    },

  myDateFormat: function(date) {
    return date.getDate() + '-' + this.months[date.getMonth()];
    }

});
