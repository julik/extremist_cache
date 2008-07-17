require File.dirname(__FILE__) + '/lib/extremist_cache'
::ActionController::Base.send(:include, ExtremistCache)
::ActionController::Base.send(:helper, ExtremistCache)
