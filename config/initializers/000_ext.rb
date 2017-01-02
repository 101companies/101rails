require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'

# # unless ENV['NO_EXT']
#   require 'fiddle'
#
#   class InstructionSequence < RubyVM::InstructionSequence; end
#
#   # require_dependency('active_record/base')
#
#   library = Fiddle::dlopen(Rails.root.join('ext', 'target', 'release', 'libext.so').to_s)
#
#   Fiddle::Function.new(library['init_ext'], [], Fiddle::TYPE_VOIDP).call
# end
