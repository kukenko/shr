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
        plan_to command
        carry_out if command.release?
        self
      end
    end

    def to_s
      carry_out
      @command_out.read if carried_out?
    end

    def inspect
      command_line = @commands.map {|c| c.first }.join(' | ').strip
      carry_out
      res =  "#<Shr::Shell>"
      res << "<:command => #{command_line}>" if command_line.size > 0
      res << "\n" << @command_out.read if carried_out?
      res
    end

    def each
      carry_out
      if carried_out?
        block_given? ? @command_out.each { |ln| yield ln } : @command_out.each
      end
    end

    def exitstatus
      carry_out
      if @wait_thread
        proc = @wait_thread.value
        proc.exitstatus
      end
    end

    def redirect_from(src)
      carry_out(:in => src)
      self
    end

    def redirect_to(dest)
      carry_out(:out => dest)
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

    def carried_out?
      @command_out && !@command_out.closed?
    end

    def plan_to(command)
      @commands << [command, command.to_proc]
    end

    def carry_out(args={})
      return if @commands.empty?

      @commands.each do |_, command|
        @command_out, @wait_thread = command.call(args, @command_out)
      end
      @wait_thread.join if @wait_thread
      @commands.clear
    end
  end
end
