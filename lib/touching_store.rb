# Will not only read the file but mark it's modification date. We can then expire
# "everything that hasn't b been used for years" to save space
class TouchingStore < ::ActionController::Caching::Fragments::FileStore
  def read(name, options = nil)
    begin
      st = Time.now
      File.utime(st, st, real_file_path(name))
      File.open(real_file_path(name), 'rb') { |f| f.read } 
    rescue
      nil
    end
  end
end