# frozen_string_literal: true

Log = Struct.new(:indent, :message)
LoggerContext = Struct.new(:indent, :logs)

# Logging handler
class Logger
  attr_accessor :terse, :verbose

  def initialize(terse: false, verbose: false)
    @terse = terse
    @verbose = verbose
    @contexts = {}
  end

  def create_context(id, title)
    @contexts[id] = LoggerContext.new(2, [Log.new(0, title)])
  end

  def write(context_id, log)
    return unless @contexts.key?(context_id)

    @contexts[context_id].logs << Log.new(@contexts[context_id].indent, log)
  end

  def write_e(context_id, log)
    return if @terse

    write(context_id, log)
  end

  def write_verbose(context_id, log)
    return unless @verbose

    write(context_id, log)
  end

  def indent(context_id, length)
    return unless @contexts.key?(context_id)

    @contexts[context_id].indent += length
  end

  def reset
    @contexts = {}
  end

  def flush
    @contexts.each do |_, context|
      next if @terse && context.logs.count <= 1

      context.logs.each do |log|
        puts "#{' ' * log.indent}#{log.message}"
      end
    end
    @contexts = {}
  end
end
