var Task = Class.create ({
  initialize: function(planning, task) {
    this.planning   = planning;
    this.name       = task.name
    this.start_date = new Date(task.start_date);
    this.duration   = task.duration_in_day;
    },

  draw: function (y) {
    this.planning.ctx.fillText(this.name, 2, y+12);
    this.planning.ctx.fillRect(this.planning.taskTitleSize, y, this.duration, 18);
    }
});

var Planning = Class.create({
  initialize: function(div_id,tasks) {
    // Actually start initializing defaults etc.
    this.div_id           = div_id || "planning";
    this.taskTitleSize    = 150;
    this.vertLinesSpacing = 50;
    this.start_date       = new Date();
    this.end_date         = new Date().getDate()+10;
    //alert(this.end_date);

    // Build up our canvas
    this.canvas        = document.createElement("canvas");
    this.canvas.id     = this.div_id + "_canvas";
    this.canvas.width  = $(this.div_id).style.width.replace(/px/, '');
    this.canvas.height = $(this.div_id).style.height.replace(/px/, '');
    // Push the canvas into our main div
    $(this.div_id).update(this.canvas);

    // Add display
    this.display    = $(document.createElement("div"));
    this.display.id = this.div_id + "_display";
    this.display.update('<div>'+this.canvas.width + 'x' + this.canvas.height +'</div>');
    $(this.div_id).insert(this.display);
    this.ctx = this.canvas.getContext("2d");

    // tasks
    this.tasks = new Array();
    for(var i=0; i < tasks.length; i++) {
      this.tasks.push(new Task(this, tasks[i].task));
      }

    // Draw the grid
    this.draw();
    },

  draw: function() {
    this.ctx.fillStyle = "rgba(100, 100, 255, 1)";
    this.ctx.font = "12px Helvetica";
    this.drawGrid();
    for(var i=0; i < this.tasks.length; i++) {
      this.tasks[i].draw(1+i*20);
      }
    },

  drawGrid: function() {
    this.ctx.lineWidth = 1;
    for(var i=0; i < this.canvas.width; i+=this.vertLinesSpacing) {
      this.ctx.beginPath();
      this.ctx.moveTo(this.taskTitleSize+i,0);
      this.ctx.lineTo(this.taskTitleSize+i,this.canvas.height);
      this.ctx.stroke();
      }
    }
});
