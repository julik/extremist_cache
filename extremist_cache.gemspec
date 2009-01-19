# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{timecode}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Julik"]
  s.date = %q{2009-01-19}
  s.description = %q{Oh please spare me.}
  s.email = ["me@julik.nl"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "init.rb", "lib/extremist_cache.rb", "lib/marking_store.rb", "lib/touching_store.rb", "test/digest_benchmark.rb", "test/test_extremist_cache.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://live.julik.nl/2008/07/cache-with-automatic-transmission}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{guerilla-di}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Oh please spare me.}
  s.test_files = ["test/test_extremist_cache.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<test-spec>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.2"])
    else
      s.add_dependency(%q<test-spec>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 1.8.2"])
    end
  else
    s.add_dependency(%q<test-spec>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 1.8.2"])
  end
end
