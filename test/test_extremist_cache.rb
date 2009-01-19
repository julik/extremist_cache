require 'rubygems'

require 'test/unit'
require 'flexmock'
require 'flexmock/test_unit'
require 'stringio'

require 'action_controller'
require 'action_controller/caching'
require 'action_controller/caching/fragments'
require 'action_controller/test_process'
require File.dirname(__FILE__)  + '/../init'

$routes = ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end


class HashingTest < Test::Unit::TestCase
  class Handle
    include ExtremistCache
    def b(*a)
      lazy_cache_key_for(*a)
    end
  end
  
  def setup
    @h = Handle.new
  end
  
  def test_hashing_yields_segmented_md5
    [1, [1,2,3], {"x" => 'y'}, Object.new].each do | value |
      assert_match /^extremist\-cache\/([a-z\d]{2})\/([a-z\d]{2})\/([a-z\d]{2})/, @h.b(value),
        "Should be a segmented path"
    end
  end
  
  def test_hashing_yields_same_hash_for_different_hashes
    assert_equal @h.b({:a => 'b', :c => 'd'}), @h.b({:c => 'd', :a => 'b'})
  end
  
  def test_hashing_depends_on_values_and_caller
    values = [
      "abcdef",
      [1, 2, 3],
      (34..190),
      {"foo" => :bar, :x => [1,5,10]},
      Object.new,
    ]
    
    via_method_a = values.inject([]) do | hashes, one |
      hashes << from_one_method(one)
    end

    via_method_a_once_again = values.inject([]) do | hashes, one |
      hashes << from_one_method(one)
    end
    
    via_method_b = values.inject([]) do | hashes, one |
      hashes << from_other_method(one)
    end

    assert_not_equal via_method_a, via_method_a_once_again, "Hashing depends on the caller"
    assert_not_equal via_method_a, via_method_b, "Hashing depends on the caller"
  end
  
  private
    def from_one_method(*a)
      @h.b(*a)
    end

    def from_other_method(*a)
      @h.b(*a)
    end
end

class BogusController < ActionController::Base
  def action_that_calls_cache
    retval = value_cached_based_on(params[:id]) { perform_expensive_computation(params[:id]) }
    
    signal_return_value(retval)
    render :nothing => true
  end
  def rescue_action(e); raise e; end
  def perform_expensive_computation(flag); return "wroom #{flag}"; end
  def signal_return_value(retval); end
  
  def action_that_renders_with_cache
    t = '<% erb_cache_based_on(params[:id]) do %> Foo<%= params[:id] %> <%= Time.now.usec %> <% end %>'
    render :inline => t
  end
end

class ValueReturnTest < Test::Unit::TestCase
  def setup
    @store = ActiveSupport::Cache.lookup_store :memory_store
    ::ActionController::Base.cache_store = @store
    
    @controller = BogusController.new
    @controller.logger = Logger.new(StringIO.new)
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    
    super
  end
  
  def test_cache_through
    wrapped_key = '123'
    
    flexmock(@controller).should_receive(:lazy_cache_key_for).with([wrapped_key]).at_least.times(6).and_return("some_key")
    
    computation_result = "abcdef #{rand}"
    flexmock(@controller).should_receive(:perform_expensive_computation).at_most.once.and_return(computation_result)
    flexmock(@controller).should_receive(:signal_return_value).with(computation_result).at_least.times(6)

    6.times do
      assert_nothing_raised { get :action_that_calls_cache, :id => wrapped_key }
    end
  end
  
  def test_cache_through_helper
    get :action_that_renders_with_cache, :id => "Poeing"
    first_body = @response.body.dup
    
    10.times { get :action_that_renders_with_cache, :id => "Poeing" }
    assert_equal first_body, @response.body
  end
end