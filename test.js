var test = {
  mtest: 2,
  
  mytest: function() {
    this.mytest2();
  },
  
  mytest2: function() {
    WScript.Echo(this.mtest);
  }

};

test.mytest();