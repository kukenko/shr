#coding: utf-8
require 'open3'
require 'shr/option'
require 'shr/which'

module Shr
  class Shell

    def initialize
      @promise = []
      @capture = false
      @release = false
    end

    def method_missing(name, *args)
      command = name.to_s.chomp('!')
      unless Which.exist?(command)
        super
      else
        delay(command, args)
        release { force } if name.to_s.end_with?('!') || @release
        self
      end
    end

    def to_s
      capture { force }
      @command_out.read if filled?
    end

    # xxx
    def inspect
      puts "#<Shr::Shell - #{@promise.join(' | ')}>"
      capture { force }
      @command_out.read if filled?
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

    def filled?
      @command_out && !@command_out.closed?
    end

    # xxx
    def command_line(name, args)
      option = Option.new
      option.indicator = '/' if OS.windows?
      options = option.parse(args).join(' ')

      if OS.windows?
        "cmd /c #{name} #{options}".strip
      else
        "#{name} #{options}".strip
      end
    end

    def delay(name, args)
      @promise << command_line(name, args)
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

    private :filled?, :command_line, :delay, :force
  end
end
