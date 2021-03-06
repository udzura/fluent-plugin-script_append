require 'fluent/plugin/script_append/version'

class Fluent::ScriptAppendOutput < Fluent::Output

  config_param :key,             :string, :default => nil
  config_param :language,        :string, :default => 'ruby'
  config_param :run_script,      :string, :default => nil
  config_param :record_var_name, :string, :default => 'record'
  config_param :new_tag,         :string, :default => nil
  config_param :prefix,          :string, :default => nil

  SUPPORTED_SCRIPT_NAME = %w(ruby sh shell)

  def configure(conf)
    super
    ensure_param_set!(:key, @key)
    ensure_param_set!(:run_script, @run_script)
    ensure_param_set!("new_tag or prefix", (@new_tag or @prefix))

    @script_runner = Object.new

    unless SUPPORTED_SCRIPT_NAME.include? @language
      warn "Plugin out_script_append would not accept 'language' value other than 'ruby'. Ignoring."
      @language = 'ruby'
    end

    case @language
    when 'ruby'
      eval <<-RUBY
        def @script_runner.run(#{@record_var_name})
          #{@run_script}
        end
      RUBY
    when 'sh', 'shell'
      script = @run_script.gsub(/`/, '\\\`')
      eval <<-RUBY
        def @script_runner.run(*)
          `#{@run_script}`
        end
      RUBY
    end
  end

  def emit(tag, event_stream, chain)
    event_stream.each do |time, record|
      rewrited_tag = get_new_tag(tag)
      record[@key] = @script_runner.run(record)
      Fluent::Engine.emit(rewrited_tag, time, record)
    end
    chain.next
  end

  private
  def get_new_tag(tag)
    if @new_tag
      @new_tag
    elsif @prefix
      [@prefix, tag].join('.')
    end
  end

  def ensure_param_set!(name, value)
    unless value
      raise Fluent::ConfigError, "#{name} must be set"
    end
  end

  Fluent::Plugin.register_output('script_append', self)
end
