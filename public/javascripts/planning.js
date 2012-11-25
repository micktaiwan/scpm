var Task = Class.create ({
  initialize: function(planning, name) {
    this.planning   = planning;
    this.name       = name
    this.start_date = Math.random()*200;
    this.duration   = Math.random()*300;
    },
  draw: function (y) {
    this.planning.ctx.fillText(this.name, 2, y+12);
    this.planning.ctx.fillRect(this.planning.taskTitleSize + this.start_date, y, this.duration, 18);
    }
});

var Planning = Class.create({
  initialize: function(div_id) {
    // Actually start initializing defaults etc.
    this.div_id         = div_id || "planning";
    this.taskTitleSize  = 50;

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
    this.tasks.push(new Task(this, "Task 1"));
    this.tasks.push(new Task(this, "Task 2"));

    // Draw the grid
    this.draw();
    },

  draw: function() {
    this.ctx.fillStyle = "rgba(100, 100, 255, 1)";
    this.ctx.font = "12px Helvetica";
    this.drawGrid
    for(var i=0; i < this.tasks.length; i++) {
      this.tasks[i].draw(1+i*20);
      }
    },

  drawGrid: function() {

    }
});
