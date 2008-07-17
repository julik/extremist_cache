class MarkingStore < ::ActionController::Caching::Fragments::MemoryStore
  EACH_NTH_REQUEST = 20
  TTL = 20.days
  class AccessMark
    include Comparable
    attr_reader :key, :atime
    def initialize(key)
      @key = key; update
    end
    
    def update
      @atime = Time.now.to_i
    end
    
    def <=>(other)
      @atime <=> other.atime
    end
  end

  def initialize
    @at_request = 0
    @marks = []
  end
  
  def write_fragment(key, value, options = nil)
    @marks << AccessMark.new(key)
    @cache[key] = value
  end
  
  def read_fragment(key, value, options = nil)
    @at_request += 1
    return nil unless @cache[key]
    
    @marks.find{|m| m.key == key }.update
    run_gc if (@at_request % EACH_NTH_REQUEST)
    @accessed[key]
  end
  
  private
    def run_gc
      threshold = (Time.now.to_i - TTL)
      @marks.sort!
      new_marks = []
      ((@marks.length *-1)..0).each do | idx |
        new_marks << @marks[idx]
        break if @marks[idx].atime < threshold
      end
      @marks = new_marks
    end
end