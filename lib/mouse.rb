class Mouse < RelativeChange
  def initialize config
    config['axi'][0] = config['axi'].delete('x')
    config['axi'][1] = config['axi'].delete('y')
    
    super config
  end
  
  def x
    axi[0].position
  end
  
  def y
    axi[1].position
  end
  
  def click ev, x=nil, y=nil
    if x or y
      abs_motion(x,y)
    end

    super ev
  end

  def press ev, x=nil, y=nil
    if x or y
      abs_motion(x,y)
    end

    super ev
  end

  def release ev, x=nil, y=nil
    if x or y
      abs_motion(x,y)
    end

    super ev
  end
  
  def drag x2, y2, x1 = x, y1 = y
    press BTN_1, x1, y1
    motion x2, y2
    release BTN_1
  end
  
  def drag_up step=5
    press BTN_1
    motion x, y-step
    release BTN_1
  end
  
  def drag_down step=5
    press BTN_1
    motion x, y+step
    release BTN_1
  end  
  
  def drag_left step=5
    press BTN_1
    motion x-step, y
    release BTN_1
  end
  
  def drag_right step=5
    press BTN_1
    motion x+step, y
    release BTN_1
  end    
  
  def center
    abs_motion axi[0].length / 2.0, axi[1].length / 2.0
  end
  
  def scroll_up step = 1
    uinput REL_WHEEL, step, 1
  end
  
  def scroll_down step = 1
    uinput REL_WHEEL, -1*step, 1
  end  
end
