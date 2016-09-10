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

  this.button = function(parent, data) {
    ele = this.row(parent).addClass('button');
    if (data && data.image) {
      image = $('<img src="'+data.image+'">')
      ele.append(image)
    }
    return ele;
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

apps = ['hbo', 'amazon', 'tv', 'music', 'browser', 'settings']

for (i=0; i<6; i++) {
  ui.button(row, {image: "icons/app/"+apps[i]+'.png'}).on('touchstart', function(e) {
    q = $('.button').index($(e.delegateTarget));
    dispatch_event(app('launch', q, {}));  
  });
}

row = ui.row(col).css({position:'relative', top: '60px'});

ui.flexNone(ui.button(row));
ui.space(row);
ui.flexNone(ui.button(row, {image: 'icons/White/Home.png'}));
ui.button(row, {image: 'icons/White/Search.png'});
ui.flexNone(ui.button(row, {image: 'icons/White/List.png'}));
ui.space(row);
ui.flexNone(ui.button(row));

row = ui.row(col);
ui.joystick(row).css({top:'98px', left:'20px'});
ui.flexMore(ui.space(row));
ui.joystick(row).css({top:'98px', left:'-20px'});

ui.flexMore(row=ui.row(col));
ui.space(row);
ui.flexNone(ui.button(row));
ui.flexNone(ui.space(row));
ui.button(row);
ui.flexNone(ui.space(row));
ui.flexNone(ui.button(row));
ui.space(row);

row = ui.row(col);
ui.joystick(row).css({top:'0px', left:'100px'});
ui.flexMore(ui.space(row));
ui.button(row);
ui.space(row);
ui.button(row);
ui.flexMore(ui.space(row));
ui.joystick(row).css({top:'0px', left:'-100px'});
