# frozen_string_literal: true

Log = Struct.new(:indent, :message)
Context = Struct.new(:indent, :logs)

class Logger

  attr_accessor :terse
  attr_accessor :verbose

  def initialize(terse = false, verbose = false)
    @terse = terse
    @verbose = verbose
    @contexts = {}
  end

  def create_context(id, title)
    @contexts[id] = Context.new(2, [Log.new(0, title)])
  end

  def write(context_id, log)
    if @contexts.key?(context_id) then
      @contexts[context_id].logs << Log.new(@contexts[context_id].indent, log)
    end
  end

  def write_e(context_id, log)
    return unless !@terse
    write(context_id, log)
  end

  def verbose(context_id, log)
    return unless @verbose
    write(context_id, log)
  end

  def indent(context_id, length)
    if @contexts.key?(context_id) then
      @contexts[context_id].indent += length
    end
  end

  def flush()
    @contexts.each do |_, context|
      next if @terse && context.logs.count <= 1
      context.logs.each do |log|
        puts "#{' ' * log.indent}#{log.message}"
      end
    end
    @contexts = {}
  end

end