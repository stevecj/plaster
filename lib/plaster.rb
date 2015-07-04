require 'active_support/hash_with_indifferent_access'
require "plaster/version"

module Plaster
  extend (module SingletonBehavior ; self ; end)

  module SingletonBehavior

    def deconstruct(obj)
      if obj.respond_to?(:to_hash)
        HashWithIndifferentAccess.new(obj.to_hash)
      elsif obj.respond_to?(:to_ary)
        Array.new(obj.to_ary)
      elsif obj.respond_to?(:to_h)
        h = obj.to_h
        h.respond_to?(:with_indifferent_access?) ?
          h.with_indifferent_access :
          HashWithIndifferentAccess.new(h)
      elsif obj.respond_to?(:each_pair)
        HashWithIndifferentAccess.new.tap do |h|
          obj.each_pair do |k,v| ; h[k] = v ; end
        end
      else
        obj
      end
    end

  end
end
