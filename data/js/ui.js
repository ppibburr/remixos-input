function UI() {
  this.flex = function(parent) {
    return this.cell(parent).addClass('flex');
  }

  this.row = function(parent) {
    return this.flex(parent).addClass('row');
  }


  this.column = function(parent) {
    return this.flex(parent).addClass('column');
  }

  this.cell = function(parent) {
    ele = $("<div>");
    parent.append(ele)
    ele.addClass('cell');
    return ele;
  }

  this.button = function(parent) {
    return this.cell(parent).addClass('button');
  }

  this.space = function(parent) {
    return this.cell(parent).addClass('space');
  }
  
  this.flexNone = function(ele) {
    ele.addClass('flex-none');
    return ele;
  }
  
  this.flexMore = function(ele) {
    $(ele).addClass('flex-more');
    return ele;
  }  
  
  this.flexN = function(ele, n) {
    ele.css('flex-grow', n);
    return ele;
  }  

  this.joystick = function(parent) {
    ele = $('<div>');
    ele.addClass('joystick');
    this.flexNone(ele);
    parent.append(ele);
    return ele;
  }
}

var ui = new UI();

col = ui.column($(document.body));
row = ui.row(col);
ui.flexNone(row);

for (i=0; i<6; i++) {
  ui.button(row);
}

ui.flexMore($('.button')[2]);

$($('.button')[2]).on('touchstart', function() {
  dispatch_event(device('mouse', 'center'));
});

row = ui.row(col);
ui.space(row);
ui.flexNone(ui.button(row));
ui.space(row);

row = ui.row(col);
ui.joystick(row).css({top:'100px', left:'20px'});
ui.flexMore(ui.space(row));
ui.joystick(row).css({top:'100px', left:'-20px'});

ui.flexMore(row=ui.row(col));
ui.space(row);
ui.button(row);
ui.space(row);

row = ui.row(col);
ui.joystick(row).css({top:'0px', left:'100px'});
ui.flexMore(ui.space(row));
ui.joystick(row).css({top:'0px', left:'-100px'});
