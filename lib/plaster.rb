require 'active_support/hash_with_indifferent_access'
require "plaster/version"
require "plaster/model_deconstruction"

module Plaster
  HashWIA = ::HashWithIndifferentAccess

  extend (
    module SingletonBehavior ; self ; end
  )

  module SingletonBehavior
    def deconstruct(obj)
      ModelDeconstruction.deconstruct(obj)
    end
  end

end
