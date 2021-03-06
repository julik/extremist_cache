require 'openssl'
module ExtremistCache
  DIGEST = OpenSSL::Digest::MD4
  VERSION = '0.0.3'
  
  # To be called from a plugin init.rb 
  def self.bootstrap!
    if !@boostrapped
      ::ActionController::Base.send(:include, ExtremistCache)
      ::ActionController::Base.send(:helper, ExtremistCache)
    end
  end
  
  # This one should be used from controllers and helpers
  def cached_based_on(*whatever)
    segmented_path = lazy_cache_key_for(*whatever)
    (@controller || self).read_fragment(segmented_path) || (@controller || self).write_fragment(segmented_path, yield)
  end
  
  # This one is for blocks that return objects, results of expensive computation
  def value_cached_based_on(*whatever)
    segmented_path = lazy_cache_key_for(whatever)
    fragment = (@controller || self).read_fragment(segmented_path)
    fragment ? Marshal.load(fragment) : returning(yield) {|f| (@controller || self).write_fragment(segmented_path, Marshal.dump(f)) }
  end
  
  def erb_cache_based_on(*whatever, &block)
    begin
      name = {:__extremist => lazy_cache_key_for(whatever)}
      @controller.fragment_for(output_buffer, name, nil, &block)
    rescue NoMethodError
      @controller.cache_erb_fragment(block, lazy_cache_key_for(*whatever))
    end
  end
  
  private
    def lazy_cache_key_for(*anything)
      calling_method = caller(2)[0..1]
      # OpenSSL's MD5 is much faster than the Ruby one - like ten times
      checksum =  DIGEST.hexdigest(Marshal.dump(calling_method + anything))
      # Splitting an MD5 on 2 symbols will give us good rainbow spread across
      # directories with 256 subdirectories max, in each given directory
      segmented_path = "extremist-cache/" + checksum.scan(/(.{2})/).join('/')
    end
end