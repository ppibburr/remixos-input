function dispatch_event(obj) {
  send(JSON.stringify(obj));
}

function app(action, id, data) {
  data['action'] = action;
  data['id']     = id;
  return event('app', data);
}

function event(type, data) {
  return {
    type: type,
    data: data
  };
}

function tap(device, source) {
  return event('tap', {
    device: device,
    source: source
  });
}

function click(device, ev, source) {
  return event('click', {
    device: device,
    ev: ev,
    source: source
  });
}

function motion(x,y, force, distance, degree, radian) {
  return event('motion', {
    force: force,
    distance: distance,
    x: x,
    y: y,
    degree: degree,
    radian: radian
  });
}

function key(action, name) {
  return event('keyboard', {
    action: action,
    key: name
  });
}

function joystick(action, axis, data) {
  ev = event('joystick', {
    action: action,
    axis: axis
  });
  
  if (action == 'create') {
    return ev;
  } else if (action == "motion") {
    ev.data['event'] = data;
  } else if (action == 'digital') {
    ev.data['direction'] = data;
  } else if (action == 'config') {
    ev.data['motion'] = data['motion'];
    ev.data['tap'] = data['tap'];
    ev.data['digital'] = data['digital'];
  }
  
  return ev;
}

function device(id, action, data) {
  ev = event('device', {
    action: action,
    name: id
  });
  
  if (action == 'config') {
    ev.data['config'] = data;
  } else {
    ev.data['args'] = data;
  }
  
  return ev;
}
