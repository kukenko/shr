#command utf-8
require 'shr/option'
require 'shr/which'

module Shr
  class Command

    def initialize(command, options=[])
      @command = command.to_s
      Option.indicator = '/' if OS.windows?
      @options = Option.translate(options).join(' ')
    end
    attr_reader :command

    def command
      command = directly? ? @command.chomp('!') : @command
      Which::builtins?(command) ? "cmd /c #{command}" : command
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
          options = { :out => io_w }
          options[:in] = command_out if command_out
          options.merge!(environment)

          pid = spawn(self.to_s, options)
          watcher = Process.detach(pid)
          io_w.close

          [io_r, watcher]
        end
      end
    end
  end
end
