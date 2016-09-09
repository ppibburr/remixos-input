
class Event
  def self.new obj
    if self != Event
      return super
    end
  
    case obj["type"]
    when "motion"
      MotionEvent.new obj
    when 'key'
      KeyEvent.new obj
    when 'keyboard'
      KeyEvent.new obj  
    when 'tap'
      TapEvent.new obj    
    when 'click'
      ClickEvent.new obj          
    when 'swipe'
      SwipeEvent.new obj
    when 'position'
      PositionEvent.new obj
    when 'app'
      AppEvent.new obj            
    when 'shell'
      ShellEvent.new obj
    when 'joystick'
      JoystickEvent.new(obj)
    when 'device'
      DeviceEvent.new(obj)
    else
      super
    end
  end
  
  def device
    Device.get(data['device'])
  end  
  
  def to_s
    "#{type} : #{action} #{data["key"]}"
  end
  
  def perform *o
    # puts "Perform: #{self}"
  end
  
  def initialize json
    @json = json
  end
  
  def type
    @json["type"]
  end
  
  def data
    @json["data"] || {}
  end
  
  def action
    data["action"]
  end
end

class KeyEvent < Event
  EVTS = {}
  CHARMAP.each_pair do |k,v|
    EVTS[k] = true
  end
  
  
  def name
    data["key"].to_sym
  end
  
  def mod
    data['mod'].to_sym
  end
  
  def action
    data['action']
  end
  
  def uinput1 *o
    $ev ||= []
    
    $ev << o
    
    $ft ||= Thread.new do
      loop do
        until ev=$ev.shift
          Thread.pass
        end
        
        if ev.length == 2
          play_click
          uinput_combo *ev
          next
        end
        
        if ev[1] == 1
          play_click
        end
        
        uinput *ev
        
      end
    end
  end
  
  def perform
    super()
    
    if action == 'adb'
      code = ADB::CHARMAP[name]

      if name == :search
        adb.search
        return
      end
      
      if name == :menu
        adb.menu
        return
      end      

      adb.keyevent code
      
      return
    end

    return unless n=CHARMAP[name]
    
    case action
    when 'click'
      uinput CHARMAP[name], 1, 1
      sleep 0.1
      uinput CHARMAP[name], 0, 1
    when 'down'
      uinput1 CHARMAP[name], 1, 1
    when 'up'
      uinput1 CHARMAP[name], 0, 1
    when 'combo'
      uinput1 CHARMAP[mod], CHARMAP[name]
    end
  end
end

class MotionEvent < Event
  def angle
    @json["data"]["degree"]
  end
  
  def radian
    @json["data"]["radian"] 
  end
  
  def distance
    d = @json["data"]["distance"]

    d = 400 * (d / 50.0)
  end
  
  def axis
    @json["axis"]
  end
  
  def perform axis
    super()
    
    axis.motion self
  end
end

class DeviceEvent < Event
  def name
    data['name']
  end
  
  def config
    data['config']
  end
  
  def perform
    super
    
    case action
    when 'config'
      Device.add name, Object::const_get(config['klass']).new(config)
      puts "Device: #{config}"
    else
      Device.get(name).send(*([action].push(*data['args'])))
    end
  rescue => e
    puts "Device: Error: #{e}\n#{e.backtrace.join("\n")}"
  end
end

class PointEvent < Event
  def x
    data['x'].to_i
  end
  
  def y
    data['y'].to_i
  end
  
  def source
    if data['source'].is_a?(String)
      Device.get(data['source'])
    elsif data['source'].is_a?(Array)
      Point.new(*data['source'])
    elsif data['source'].is_a?(Hash)
      Point.new(data['source']['x'], data['source']['y'])
    elsif x and y
      Point.new(x, y)
    else
      device
    end
  end
  
  def perform
    return unless device and source
    super
  end  
end

class Point2PointEvent < PointEvent
  def x1
    data['x1'].to_i
  end
  
  def y1
    data['y1'].to_i
  end  
  
  def amt
    data['amt'] ||= 5
  end
  
  def direction
    data['direction']
  end
end

module TouchEvent
  def device
    d = super
    if d ==  device
      nil
    else
      d
    end
  end
end

class SwipeEvent < Point2PointEvent    
  include TouchEvent
  
  def perform
    super()
    
    return unless source and device
    
    if direction
      case direction
      when 'up'
        device.swipe_up source, amt
      when 'down'
        device.swipe_down source, amt
      when 'left'
        device.swipe_left source, amt
      when 'right'
        device.swipe_right source, amt
      end
      
      return
    end
      
    qx = source.x
    qy = source.y
      
    device.swipe qx,qy,x1,y1
  end
end

class DragEvent < Point2PointEvent    
  def perform
    super()
    
    return unless device
    
    if direction
      case direction
      when 'up'
        device.drag_up source, amt
      when 'down'
        device.drag_down source, amt
      when 'left'
        device.drag_left source, amt
      when 'right'
        device.drag_right source, amt
      end
      
      return
    end
      
    qx = source.x
    qy = source.y
      
    device.drag qx,qy,x1,y1
  end
end


class PositionEvent < PointEvent
  def perform
    super
    
    device.move_to source.x, source.y
  rescue
  end
end

class TapEvent < PointEvent  
  include TouchEvent
  
  def perform
    super()
    
    device.tap source.x, source.y 
  rescue
  end
end

class ClickEvent < PointEvent
  def ev
    Object.const_get(data['ev'])
  rescue
  end

  def perform
    super()

    return unless ev
    
    if source != device
      device.click ev, source.x, source.y
    else
      device.click ev
    end
  rescue
  end
end

class AppEvent < Event
  def id
    data['id']
  end
  
  def menu
    data['menu']
  end
  
  def search
    data['search']
  end
  
  def package
    data['package']
  end

  def perform
    super
    
    case action
    when 'config'
      App.add(id, App.new(package, search, menu))
      puts "App: #{data}"
    when 'launch'
      adb.launch((app=App.find(id)) ? app.package : package)
    end
  end
end

class ShellEvent < Event
  def action
    data['action']
  end

  def perform s
    super()
  
    case action
    when 'feed'
      Shell.instances[s].feed data['body']
    when 'term'
      Shell.instances[s].terminate
    end
  end
end

class JoystickEvent < Event
  def axis
    data['axis']
  end

  def perform
    super()
    
    case action
    when 'create'
      Axis.new
      puts "Joystick: #{data}"
      return
    end
    
    Axis::instances[axis].dispatch self
  end
end

def dispatch_event json
  json = json.to_json unless json.is_a?(String)

  evt = Event.new(JSON.parse(json)).perform
end
