require 'helper'

class ScriptAppendOutputTest < Test::Unit::TestCase
  def create_driver(conf ,tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::ScriptAppendOutput, tag).configure(conf)
  end

  setup do
    Fluent::Test.setup
  end

  CONFIG_DEFAULT = <<-FLUENTD
    key sample
    language ruby
    run_script "Hello, World"
    new_tag test.result
  FLUENTD

  test 'configure' do
    d = create_driver CONFIG_DEFAULT
    assert_equal "sample", d.instance.config['key']
    assert_equal '"Hello, World"', d.instance.config['run_script']
  end

  test 'appends a result' do
    config = <<-FLUENTD
      key sample
      language ruby
      run_script "Hello, World"
      new_tag test.result
    FLUENTD

    d = create_driver CONFIG_DEFAULT, 'input.access'
    d.run do
      d.emit({'domain' => 'www.google.com', 'path' => '/foo/bar?key=value', 'agent' => 'Googlebot', 'response_time' => 1000000})
    end

    emits = d.emits
    assert_equal 'test.result', emits[0][0]
    assert_equal 'Hello, World', emits[0][2]['sample']
  end
end
