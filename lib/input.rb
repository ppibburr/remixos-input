class UInput
  def initialize
    @in, @out, @err = Open3.popen3("python ../bin/uinput #{ARGV.index("touch") ? "" : "no-"}touch")
  end
  
  def puts s
    return unless s.split(" ").length >= 2

    @in.puts s 
  end
end

class ADB
  CHARMAP = {
    '0'.to_sym => i=7,
    '1'.to_sym => i+=1,    
    '2'.to_sym => i+=1,
    '3'.to_sym => i+=1,
    '4'.to_sym => i+=1,
    '5'.to_sym => i+=1,
    '6'.to_sym => i+=1,
    '7'.to_sym => i+=1,
    '8'.to_sym => i+=1,
    '9'.to_sym => i+=1,
    'a'.to_sym => i=29,                            
    'b'.to_sym => i+=1,
    'c'.to_sym => i+=1,
    'd'.to_sym => i+=1,
    'e'.to_sym => i+=1, 
    'f'.to_sym => i+=1,
    'g'.to_sym => i+=1,
    'h'.to_sym => i+=1,
    'i'.to_sym => i+=1,
    'j'.to_sym => i+=1,
    'k'.to_sym => i+=1,
    'l'.to_sym => i+=1,
    'm'.to_sym => i+=1,
    'n'.to_sym => i+=1,
    'o'.to_sym => i+=1,
    'p'.to_sym => i+=1,
    'q'.to_sym => i+=1,
    'r'.to_sym => i+=1,
    's'.to_sym => i+=1,
    't'.to_sym => i+=1,
    'u'.to_sym => i+=1,     
    'v'.to_sym => i+=1,
    'w'.to_sym => i+=1,
    'x'.to_sym => i+=1,
    'y'.to_sym => i+=1,    
    'z'.to_sym => i+=1,
    ','.to_sym => i+=1,
    '.'.to_sym => i+=1,            
    'Shift'.to_sym => 59,
    'Tab'.to_sym => 61,
    'Enter'.to_sym => 66,
    'Space'.to_sym => 62,
    'BkSp'.to_sym => 67,
    :media_toggle  => 85,
    :home          => 3,
    :back          => 4,
    :menu          => 82,
    :search        => 84
  }

  def initialize
    @in, @out, @err = Open3.popen3("adb shell")
  end
  
  def puts s
    @in.puts s 
  end
  
  def event dev, event, code, val
    puts "sendevent #{dev} #{code} #{val}"
  end
  
  def sync dev
    input dev, 0, 0, 0
  end
  
  def text str
    puts "input text \"#{str.gsub(" ", "%s")}\""
  end
  
  def launch q
    if app = App.find(q)
      puts "monkey -p #{app.package} 1"
      return
    end
    
    puts "monkey -p #{q} 1"
  end
  
  def keyevent code 
    puts "input keyevent #{code}"
  end
  
  def tap x,y
    puts "input tap #{x.to_i} #{y.to_i}"
  end
  
  def swipe x,y,x1,y1
    puts "input swipe #{x.to_i} #{y.to_i} #{x1.to_i} #{y1.to_i}"
  end
  
  def active
    `adb shell dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp'`.scan(/\b[a-z]+\..*?\//)[0].gsub("/",'')
  end
  
  def search
    if App.find(active)
      app.search
    else
      keyevent 84
    end
  end
  
  def menu
    if App.find(active)
      app.menu
    else
      keyevent(82)
    end
  end   
end

def adb
  @adb ||= ADB.new
rescue
  @adb = nil
end

def uinput ev, v, sync = 1
  @uinput ||= UInput.new
  @uinput.puts "#{ev} #{v.to_i} #{sync}"
end

def uinput_combo ev1, ev2
  @uinput ||= UInput.new

  @uinput.puts "#{ev1} #{ev2}"
end
