# typed: false
# frozen_string_literal: true

require 'tty-exit'

def leave(code)
  return TTY::Exit.exit_code(code)
end

def leave_with(code, msg)
  return TTY::Exit.exit_with(code, msg)
end

def import_failure
  puts '[!] Try "bundle install"'
  leave(:config_error)
end
