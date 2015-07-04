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
      if obj.respond_to?( :model_deconstruct )
        obj.model_deconstruct
      elsif obj.respond_to?( :to_hash )
        HashWIA.new( obj.to_hash )
      elsif obj.respond_to?( :to_ary )
        Array.new( obj.to_ary )
      elsif obj.respond_to?( :to_h )
        h = obj.to_h
        h.respond_to?( :with_indifferent_access? ) ?
          h.with_indifferent_access :
          HashWIA.new( h )
      elsif obj.respond_to?( :each_pair )
        HashWIA.new.tap do |h|
          obj.each_pair do |k,v| ; h[k] = v ; end
        end
      else
        obj
      end
    end
  end

end
