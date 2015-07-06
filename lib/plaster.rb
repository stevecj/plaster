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
