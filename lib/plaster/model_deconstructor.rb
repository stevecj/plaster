require 'active_support/hash_with_indifferent_access'

module Plaster

  class ModelDeconstructor

    class << self
      extend Forwardable

      def_delegator :default_instance, :call

      def default_instance
        @default_instance ||= new
      end
    end

    def self.default_instance
      @default_instance ||= new
    end

    def call(obj)
      if obj.nil? || true == obj || false == obj
        obj
      elsif obj.respond_to?( :model_deconstruct )
        obj.model_deconstruct
      elsif obj.respond_to?( :to_hash )
        HashWIA.new( obj.to_hash )
      elsif array_like?( obj )
        Array.new( obj.to_a )
      elsif hash_analogous?( obj )
        HashWIA.new( obj.to_h )
      elsif map_analogous?( obj )
        deconstruct_from_pairs( obj )
      else
        obj
      end
    end

    def array_like?(obj)
      return true if \
        obj.respond_to?( :to_ary )

      return false if \
        obj.respond_to?( :to_hash )

      obj.respond_to?( :to_a   ) &&
      obj.respond_to?( :each   ) &&
      obj.respond_to?( :+      )
    end

    def hash_analogous?(obj)
      obj.respond_to?( :to_h ) &&
      obj.respond_to?( :each_pair )
    end

    def map_analogous?(obj)
      obj.respond_to?( :each_pair ) &&
      obj.respond_to?( :values    ) &&
      obj.respond_to?( :[]        )
    end

    def deconstruct_from_pairs(obj)
      HashWIA.new.tap do |h|
        obj.each_pair do |k,v| ; h[k] = v ; end
      end
    end
  end

end
