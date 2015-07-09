
# The only thing that Plaster really requires ActiveSupport for
# at this time is HashWithIndifferentAccess. In order to make
# that work right, however, one mus require at least
# 'active_support_core_extensions/hash', which in turn requires
# most (or maybe all) of ActiveSupport anyway.
# FIXME: Perhaps use ActiveSupport if present, or fall back to
#        an alternative implementation of
#        HasWithIndifferentAccess
require 'active_support/all'

require "plaster/version"
require "plaster/model_deconstructor"
require "plaster/wrapping_list"

module Plaster
  HashWIA = ::HashWithIndifferentAccess

  extend (
    module SingletonBehavior ; self ; end
  )

  module SingletonBehavior
    def deconstruct(obj)
      ModelDeconstructor.call(obj)
    end

    def []()
      WrappingList
    end
  end

end
