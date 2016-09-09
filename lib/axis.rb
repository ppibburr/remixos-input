class Axis
  attr_reader :device
  
  def self.instances
    @instances ||= []
  end
  
  def initialize
    self.class.instances << self
    @digital = {}
    @threads = {}
  end
  
  def dispatch evt
    case evt.action
    when 'config'
      config evt.data
    when 'start'
      on_start
    when 'end'
      on_end
    when 'digital'
      on_digital(evt.data['direction'].to_sym)
    when 'motion'
      on_motion(Event.new(evt.data['event']))
    end
  end
  
  def motion evt
    return unless @active
    
    if evt.distance > 3 #@thresh_hold
      @move = true

      return unless @device and @device.respond_to?(:motion)

      @evt = evt
    
      @thread ||= Thread.new do
        while true
        begin
          break unless @active
          evt = @evt

          speed = (evt.distance / 5.0) * 10
          [x=evt.distance * Math.cos(evt.angle * Math::PI / 180 ), y=evt.distance * Math.sin(evt.angle * Math::PI / 180 )];
          podx, pody = [x / evt.distance.to_f,  y / evt.distance.to_f].map do |q| q.round(2) end
                #p [x,y, podx, pody]
          @dx, @dy = [podx * speed / 100, pody * speed / 100].map do |q| q.abs < 1 ? 0 : q end
          
         # puts "\nmotion: [#{@dx}, #{@dy}]\n"
          
          device.motion @dx,-1*@dy
          
          sleep 0.01
          Thread.pass

        rescue => e
          p e
        end
        end
      end
    end
  end
  
  def on_start
    @active = true
    @move   = false
    @act_dig = nil
  end
  
  def on_end
    @active = false
    
    if @act_dig
      if t=@threads[@act_dig.to_sym]
        t.kill
        @threads[@act_dig.to_sym] = nil
      end
      on_digital @act_dig, :low
    end 
    
    @thread.kill if @thread
    
    @thread = nil
    
    if !@move
      on_tap
    end
    
    @move = false
  end
  
  def on_motion evt = nil, &b  
    if b
      @motion = b
      return
    end
    
    if (cb=@motion)
      @motion.call evt
    end
  end
  
  def on_digital arg, state=:high, &b
    if o=@act_dig
      @act_dig = nil
      on_digital o, :low unless state == :low
    end
    
    @act_dig = arg if state == :high
  
     if b
       (@digital[arg] ||= {})[state] = b
       return
     end
     
     if cb=(@digital[arg] ||= {})[state]
       p [arg, state]
       cb.call
     end
  end
  
  def on_tap &b
    if b
      @tap = b
      return
    end
    
    if @tap
      @tap.call
    end
  end
  
  def config o 
    if o['digital']
    p o, :DIGI
      ['up', 'down', 'left', 'right'].each do |name|
        dir   = o['digital'][name]
        
        next unless dir
        
        ['high', 'low'].each do |state|
          evt = dir[state]
          
          next unless evt
           
          on_digital name.to_sym, state.to_sym do
            if t=@threads[name.to_sym]
              t.kill
              @threads[name.to_sym] = nil
            end
            
            if rpt=dir['repeat'] and state.to_sym == :high
              @threads[name.to_sym] = Thread.new do
                loop do
                  dispatch_event(evt)
                  sleep rpt['rate'] ||= 0.3
                end
              end
              next
            end
            
            dispatch_event(evt)
          end
        end
      end
    end
    
    if evt = o['tap']
      on_tap do
        dispatch_event(evt)
      end
    end
    
    if o['motion']
      begin
        @device = Device.get(o['motion']['bind'])
        
        on_motion() do |evt|
          evt.perform self
        end
      rescue
      end
    end
  rescue => e
    puts "Conf: error #{e}\n#{e.backtrace.join("\n")}"
  end
end


if __FILE__ == $0
  require "json"
  require "open3"
  
  require "./ev.rb"
  require "./input.rb"  
  require "./device.rb"  
  require "./app.rb"  
  require "./events.rb"
  require "./actions.rb"
  require "./mouse.rb"    
    
  center_mouse = {
    type: 'device',
    data: {
      name: 'mouse',
      action: 'center'
    }
  }  

  dispatch_event({
    type: 'app',
    
    data: {
      action: 'config',
      package: 'com.sling',
      id: 'tv',
    }
  })
  
  dispatch_event({
    type: 'app',
    
    data: {
      action: 'config',
      package: 'com.android.chrome',
      id: 'browser',
    }
  })  
  
  dispatch_event({
    type: 'app',
    
    data: {
      action: 'config',
      package: 'com.spotify.music',
      id: 'music',
    }
  })    

  dispatch_event({
    type: 'app',
    
    data: {
      action: 'config',
      package: 'com.HBO',
      id: 'hbo',
      
      search: [
        {
          type: 'tap',
          data: {
            source: {
              x: 1620,
              y: 20
            }
          },
        },
      
        center_mouse
      ],
      
      menu: [{
        type: 'tap',
        data: {
          source: {
            x: 26,
            y: 60
          }
        }
      }, center_mouse]
    }
  }) 
    
  dispatch_event({
    type: 'app',
    
    data: {
      action: 'config',
      package: 'com.amazon.avod.thirdpartyclient',
      id: 'amazon',
      
      search: [
        {
          type: 'tap',
          data: {
            source: {
              x: 1830,
              y: 90
            }
          },
        },
      
        center_mouse
      ],
      
      menu: [{
        type: 'tap',
        data: {
          source: {
            x: 26,
            y: 60
          }
        }
      }, center_mouse]
    }
  })  
    
  dispatch_event({
    type: 'device',
    data: {
      action: 'config',
      name: 'mouse',
      
      config: {
        klass: 'Mouse',
      
        axi: {
          x: ['REL_X', 1366],
          y: ['REL_Y', 768]
        }
      }
    }
  })
  
  dispatch_event(center_mouse)  
  
  dispatch_event({
    type: 'joystick',
    
    data: {
      action: 'create',
    }
  })
    
  dispatch_event({
    type: 'joystick',
    data: {
      action: 'config',
      axis: 0,
      
      motion: {
        bind: 'mouse'
      },
      
      tap: {
        type: 'keyboard',
        data: {
          key: 'btn_3',
          action: 'click'
        }
      }
    }
  });  

  dispatch_event({
    type: 'joystick',
    data: {
      action: 'start',
      axis: 0
    }
  })
  
  359.times do |i|
    dispatch_event({
      type: "joystick",
      data: {
        axis: 0,
        action: 'motion',
        event: {
          type: 'motion',
          data: {
            force: rand(100),
            x: rand(100),
            y: rand(100),
            distance: 25,
            degree: i,
            radian: nil
          }
        }
      }
    })
    
    sleep 0.01
  end
  
  dispatch_event({
    type: 'joystick',
    data: {
      action: 'end',
      axis: 0
    }
  })   
  
  dispatch_event({
    type: 'keyboard',
    data: {
      key: 'a',
      action: 'down'
    }
  })
  
  dispatch_event({
    type: 'keyboard',
    data: {
      key: 'a',
      action: 'up'
    }
  })  

  dispatch_event({
    type: 'keyboard',
    data: {
      key: 'b',
      action: 'click'
    }
  })    

  dispatch_event({
    type: 'click',
    data: {
      device: 'mouse',
      ev: 'BTN_1',
      source: {
        x:500,
        y:500
      }
    }
  })
  
  sleep 0.3
  
  dispatch_event({
    type: 'joystick',
    data: {
      action: 'start',
      axis: 0
    }
  }) 
  
  dispatch_event({
    type: 'joystick',
    data: {
      action: 'end',
      axis: 0
    }
  })     
end


