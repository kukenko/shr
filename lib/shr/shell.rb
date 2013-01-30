#coding: utf-8
require 'shr/command'
require 'shr/builtin'

module Shr
  class Shell

    include Builtin

    def initialize
      @commands = []
    end

    def method_missing(name, *args)
      command = Command.new(name, args)
      unless command.exist?
        super
      else
        delay command
        force if command.release?
        self
      end
    end

    def to_s
      force
      @command_out.read if filled?
    end

    def inspect
      command_line = @commands.map {|c| c.first }.join(' | ').strip
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

    def bake(name, command, options=[])
      Shell.class_eval do
        define_method(name) do |*args|
          self.method_missing(command, *(options + args))
        end
      end
    end

    private

    def filled?
      @command_out && !@command_out.closed?
    end

    def delay(command)
      @commands << [command, command.to_proc]
    end

    def force(args={})
      return if @commands.empty?

      @commands.each do |_, command|
        @command_out, @wait_thread = command.call(args, @command_out)
      end
      @wait_thread.join if @wait_thread
      @commands.clear
    end
  end
end
