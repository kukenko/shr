#coding: utf-8
require 'shr/option'
require 'shr/which'

module Shr
  class Command

    def initialize(command, options=[])
      @command = command.to_s
      Option.indicator = '/' if OS.windows?
      @options = Option.translate(options).join(' ')
    end

    def to_s
      [command, @options].join(' ')
    end

    def exist?
      Which::exist? @command.chomp('!')
    end

    def directly?
      @command.end_with? '!'
    end

    def to_proc
      Proc.new do |environment, command_out|
        if directly?
          Process.detach(spawn self.to_s).join
          [nil, nil]
        else
          io_r, io_w = IO.pipe
          fds = { :out => io_w }
          fds[:in] = command_out if command_out
          fds.merge! environment

          watcher = Process.detach(spawn self.to_s, fds)
          io_w.close

          [io_r, watcher]
        end
      end
    end

    private

    def command
      c = @command.chomp('!')
      Which::builtins?(c) ? "cmd /c #{c}" : c
    end
  end
end
