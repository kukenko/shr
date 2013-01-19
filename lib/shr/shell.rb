#coding: utf-8
require 'open3'
require 'shr/command'

module Shr
  class Shell

    def initialize
      @promise = []
      @capture = false
      @release = false
    end

    def method_missing(name, *args)
      command = Command.new(name, args)
      unless command.exist?
        super
      else
        delay command
        release { force } if command.release? || @release
        self
      end
    end

    def to_s
      capture { force }
      @command_out.read if filled?
    end

    def inspect
      command_line = @promise.join(' | ').strip
      capture { force }
      res = ''
      res << "#<Shr::Shell>"
      res << "<:command => #{command_line}>" if command_line.size > 0
      res << "\n" if filled?
      res << @command_out.read if filled?
      res
    end

    def capture(&block)
      @capture = true
      instance_exec(&block)
      @capture = false
    end

    def release(&block)
      @release = true
      instance_exec(&block)
      @release = false
    end

    def each
      capture { force }
      if filled?
        block_given? ? @command_out.each { |ln| yield ln } : @command_out.each
      end
    end

    def exitstatus
      capture { force }
      if @wait_thread
        proc = @wait_thread.value
        proc.exitstatus
      end
    end

    def redirect_from(src)
      capture { force(:redirect => { :in => src }) }
      self
    end

    def redirect_to(dest)
      release { force(:redirect => { :out => dest }) }
    end

    alias_method :<, :redirect_from
    alias_method :>, :redirect_to

    private

    def filled?
      @command_out && !@command_out.closed?
    end

    def delay(command)
      @promise << command.to_s
    end

    def force(args={})
      args = { :redirect => {} }.merge(args)
      return if @promise.empty?

      if @release
        Open3.pipeline(*@promise, args[:redirect])
      elsif @capture
        out, thr = Open3.pipeline_r(*@promise, args[:redirect])
        @command_out = out
        @wait_thread = thr[-1]
      end

      @promise.clear
    end
  end
end
