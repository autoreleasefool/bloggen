# frozen_string_literal: true

Log = Struct.new(:indent, :message)
Context = Struct.new(:indent, :logs)

class Logger

  def initialize(verbose = false)
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

  def verbose(context_id, log)
    if @verbose then
      write(context_id, log)
    end
  end

  def indent(context_id, length)
    if @contexts.key?(context_id) then
      @contexts[context_id].indent += length
    end
  end

  def flush()
    @contexts.each do |_, context|
      context.logs.each do |log|
        puts "#{' ' * log.indent}#{log.message}"
      end
    end
    @contexts = {}
  end

end