require 'helper'

class ScriptAppendOutputTest < Test::Unit::TestCase
  def create_driver(conf ,tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::ScriptAppendOutput, tag).configure(conf)
  end

  setup do
    Fluent::Test.setup
  end

  test 'configure' do
    config = <<-FLUENTD
      key sample
      language ruby
      run_script "Hello, World"
      new_tag test.new
    FLUENTD

    d = create_driver config
    assert_equal "sample", d.instance.config['key']
    assert_equal '"Hello, World"', d.instance.config['run_script']
  end

  test 'appends a result' do

  end
end
