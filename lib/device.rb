class Device
  def self.add name, device
    @map ||= {}
    
    @map[name] = device
  end
  
  def self.get name
    @map ||= {}
    
    @map[name]
  end

  attr_reader :config
  def initialize cfg
    @config = cfg
  end

  def click ev

    press ev
    release ev
  end

  def press ev

    play_click

    uinput ev,1,1
  end

  def release ev

    uinput ev,0,1
  end
end

class AxisDevice < Device
  class self::Axis
    attr_accessor :length
    attr_reader :position, :ev
    def initialize ev, length, position = 0
      @length   = length
      @ev       = ev
      @position = position
    end
    
    def motion v, sync = true
      uinput(ev, v, (sync == true) ? 1 : 0)
      self.position = v
    end
    
    def increment i
      q = @position + i
      
      self.position = q 
    end
    
    def position= q
      @position = q
     
      @position = length if q > length
      @position = 0      if q < 0
    end
  end
  
  attr_reader :axi
  def initialize config
    @axi = []
    
    super config
    
    for i in 0..(a=config['axi']).length-1
      append_axis(Object.const_get(a[i][0]), a[i][1], a[i][2] || 0)
    end
  end
  
  def append_axis ev, length, position = 0
    @axi << self.class::Axis.new(ev, length, position)
  end
  
  def motion *o
    axi.each_with_index do |a, i|
      a.motion o[i], true
    end
  end
  
  def move_to x,y
    motion x,y
  end  
end

class RelativeChange < AxisDevice
  def abs_motion *o
    axi.each_with_index do |a,i|
      uinput a.ev, -a.length, 1
      a.position = 0
    end
    
    sleep 0.3
    
    motion *o, true
  end
  
  def motion *o
    if o.last == true or o.last == false or o.last == nil
      bool = o.pop
    end
    
    old = axi.map do |q| q.position end
    
    super *o
    
    unless bool
      old.each_with_index do |v, i|
        axi[i].position = v + o[i]
      end 
    end
  end
  
  def move_to x,y
    abs_motion x,y
  end  
end

class Point
  attr_accessor :x,:y
  def initialize x,y
    @x=x
    @y=y
  end
end

class TouchScreen < Device
  def swipe x1, y1, x2, y2
    adb.swipe x1,y1,x2,y2
  end
  
  def swipe_up source, step=5
    swipe source.x, source.y, source.x, source.y-step  
  end
  
  def swipe_down source, step=5
    swipe source.x, source.y, source.x, source.y+step  
  end
  
  def swipe_right source, step=5
    swipe source.x, source.y, source.x+step, source.y
  end
  
  def swipe_left source, step=5
    swipe source.x, source.y, source.x-step, source.y
  end
  
  def tap source
    adb.tap source.x, source.y
  end
end
