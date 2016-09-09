class App
  def self.add id, ins
    @map ||= {}
    
    @map[id] = ins
  end
  
  def self.get id
    @map ||= {}
    
    @map[id]
  end
  
  def self.find q
    @map ||= {}
    
    app = @map[q]
    
    return app if app
    
    app=@map.find do |id, a|
      a.package == q
    end
    
    return app
  end

  attr_reader :package
  def initialize package, search, menu
    @package = package
    @search  = search
    @menu    = @menu
  end 
  
  def search
    if @search
      if @search.is_a?(Array)
        @search.each do |e|
          dispatch_event e.to_json
        end
        return
      elsif @search.is_a?(Hash)
        dispatch_event(@search.to_json)
        return
      end
    end
    
    adb.keyevent 84
  end
  
  def menu
    if @menu
      if @menu.is_a?(Array)
        @menu.each do |e|
          dispatch_event e.to_json
        end
        return
      elsif @menu.is_a?(Hash)
        dispatch_event(@menu.to_json)
        return
      end
    end
    
    adb.keyevent 82
  end  
end

