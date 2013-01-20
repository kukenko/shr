#coding: utf-8
require 'shr/command'

module Shr
  class Shell

    def initialize
      @promise = []
    end

    def method_missing(name, *args)
      command = Command.new(name, args)
      unless command.exist?
        super
      else
        delay command
        force! if command.release?
        self
      end
    end

    def to_s
      force
      @command_out.read if filled?
    end

    def inspect
      command_line = @promise.join(' | ').strip
      force
      res =  "#<Shr::Shell>"
      res << "<:command => #{command_line}>" if command_line.size > 0
      res << "\n" if filled?
      res << @command_out.read if filled?
      res
    end

    def each
      force
      if filled?
        block_given? ? @command_out.each { |ln| yield ln } : @command_out.each
      end
    end

    def exitstatus
      force
      if @wait_thread
        proc = @wait_thread.value
        proc.exitstatus
      end
    end

    def redirect_from(src)
      force(:in => src)
      self
    end

    def redirect_to(dest)
      force(:out => dest)
    end

    alias_method :<, :redirect_from
    alias_method :>, :redirect_to

    private

    def filled?
      @command_out && !@command_out.closed?
    end

    def delay(command)
      @promise << command
    end

    # xxx
    def force(args={})
      return if @promise.empty?

      @promise.each do |promise|
        io_r, io_w = IO.pipe
        environment = { :out => io_w }
        environment[:in] = @command_out if @command_out
        environment.merge!(args)

        watcher = promise.run(environment)

        @command_out = io_r
        @wait_thread = watcher
      end

      @promise.clear
    end

    # xxx
    def force!
      return if @promise.empty?

      @promise[-1].run!
      @promise.clear
    end
  end
end
