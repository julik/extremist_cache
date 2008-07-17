require 'openssl'
require 'digest'
    
lets = ("a".."z").to_a

require 'benchmark'

[Digest::MD5, OpenSSL::Digest::MD5,  OpenSSL::Digest::MD4, OpenSSL::Digest::SHA1].each do | d |
  
  puts "\n\n #{d} with value digest"
  Benchmark.bm do | x|
    hundred_values = (0..100).map { (0..100).map { lets[rand(lets.length)]}.join }
    
    x.report do
      300.times do
        hundred_values.map {|let| d.hexdigest(Marshal.dump(let)) }
      end
    end
  end

  puts "\n\n #{d} with hash digest"
  Benchmark.bm do | x|
    hundred_values = (0..100).map { (0..100).map { lets[rand(lets.length)]}.join }
    
    x.report do
      300.times do
        hundred_values.map {|let| d.hexdigest(Marshal.dump(let).hash.to_s) }
      end
    end
  end

end
