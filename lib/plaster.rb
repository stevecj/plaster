require "plaster/version"
require "plaster/model_deconstructor"

module Plaster
  HashWIA = ::HashWithIndifferentAccess

  extend (
    module SingletonBehavior ; self ; end
  )

  module SingletonBehavior
    def deconstruct(obj)
      ModelDeconstructor.call(obj)
    end
  end

end
