require 'rubygems'
require 'hoe'
require './lib/extremist_cache'

Hoe::RUBY_FLAGS.replace ENV['RUBY_FLAGS'] || "-I#{%w(lib ext bin test).join(File::PATH_SEPARATOR)}" +
  (Hoe::RUBY_DEBUG ? " #{RUBY_DEBUG}" : '')

Hoe.new('timecode', ExtremistCache::VERSION) do |p|
  p.developer('Julik', 'me@julik.nl')
  p.extra_deps.reject! {|e| e[0] == 'hoe' }
  p.extra_deps << 'test-spec'
  p.rubyforge_name = 'guerilla-di'
  p.remote_rdoc_dir = 'timecode'
end

begin
  require 'load_multi_rails_rake_tasks'
rescue LoadError
end
