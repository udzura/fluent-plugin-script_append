require 'helper'

class ScriptAppendOutputTest < Test::Unit::TestCase
  def create_driver(conf, tag='test')
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

  def config_with_run_script(script)
    CONFIG_DEFAULT.sub(
      /^ +run_script.*$/,
      "run_script #{script}"
    )
  end

  test 'configure' do
    d = create_driver CONFIG_DEFAULT
    assert_equal "sample", d.instance.config['key']
    assert_equal '"Hello, World"', d.instance.config['run_script']
  end

  test 'invalid config' do
    assert_raise Fluent::ConfigError do
      create_driver <<-FLUENTD
        language ruby
        run_script "Hello, World"
        new_tag test.result
      FLUENTD
    end

    assert_raise Fluent::ConfigError do
      create_driver <<-FLUENTD
        key invakid
        language ruby
        new_tag test.result
      FLUENTD
    end

    assert_raise Fluent::ConfigError do
      create_driver <<-FLUENTD
        key invakid
        language ruby
        run_script "Hello, World"
      FLUENTD
    end

    assert_nothing_raised do
      create_driver <<-FLUENTD
        key invalid
        run_script "Hello, World"
        new_tag test.result
      FLUENTD
    end
  end

  test 'appends a result' do
    d = create_driver CONFIG_DEFAULT, 'input.access'
    d.run do
      d.emit({'domain' => 'www.google.com', 'path' => '/foo/bar?key=value', 'agent' => 'Googlebot', 'response_time' => 1000000})
    end

    emits = d.emits
    assert_equal 'test.result', emits[0][0]
    assert_equal 'Hello, World', emits[0][2]['sample']
  end

  test 'appends a result using record' do
    d = create_driver config_with_run_script("record['one'].to_i + record['two'].to_i")
    d.run do
      d.emit({'one' => 1, 'two' => 2})
    end

    emits = d.emits
    assert_equal 'test.result', emits[0][0]
    assert_equal 3, emits[0][2]['sample']
  end

  test 'appends with prefix' do
    d = create_driver CONFIG_DEFAULT.sub(/new_tag.*$/m, 'prefix the_prefix'), 'with_suffix'
    d.run do
      d.emit({'domain' => 'www.google.com', 'path' => '/foo/bar?key=value', 'agent' => 'Googlebot', 'response_time' => 1000000})
    end

    emits = d.emits
    assert_equal 'the_prefix.with_suffix', emits[0][0]
    assert_equal 'Hello, World', emits[0][2]['sample']
  end

  test 'customizes variable name in script' do
    d = create_driver \
      config_with_run_script("data['one'].to_i + data['two'].to_i * 10").
      sub(/\z/, "\n record_var_name data")
    d.run do
      d.emit({'one' => 1, 'two' => 2})
    end

    emits = d.emits
    assert_equal 21, emits[0][2]['sample']
  end

  test 'runs shell via Kernel#`' do
    d = create_driver \
      config_with_run_script(%{echo "Hello world via shell"}).
      sub(/language.*$/, "language shell")

    d.run do
      d.emit({'domain' => 'www.google.com', 'path' => '/foo/bar?key=value', 'agent' => 'Googlebot', 'response_time' => 1000000})
    end

    emits = d.emits
    assert_equal "Hello world via shell\n", emits[0][2]['sample']
  end
end
