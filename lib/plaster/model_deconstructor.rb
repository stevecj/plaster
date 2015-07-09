module Plaster

  # Deconstructs a hierarchical data structure comprised of
  # struct-like and array-like objects into a homologous
  # structure of hashes (HashWithIndifferentAccess) and arrays
  # (Array).
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
        deconstruct_from_hash( obj )
      elsif bag_like?( obj )
        deconstruct_from_bag_like( obj )
      elsif hash_like?( obj )
        deconstruct_from_hash_like( obj )
      elsif map_like?( obj )
        deconstruct_from_map_like( obj )
      else
        obj
      end
    end

    def bag_like?(obj)
      return true if \
        obj.respond_to?( :to_ary )

      return false if \
        obj.respond_to?( :to_hash )

      obj.respond_to?( :to_a   ) &&
      obj.respond_to?( :each   ) &&
      obj.respond_to?( :map    ) &&
      obj.respond_to?( :&      ) &&
      obj.respond_to?( :|      ) &&
      obj.respond_to?( :+      ) &&
      obj.respond_to?( :-      )
    end

    def hash_like?(obj)
      obj.respond_to?( :to_h      ) &&
      obj.respond_to?( :each_pair )
    end

    def map_like?(obj)
      obj.respond_to?( :each_pair ) &&
      obj.respond_to?( :values    ) &&
      obj.respond_to?( :[]        )
    end

    def deconstruct_from_hash(hash)
      hash = HashWIA.new( hash.to_hash )
      deconstruct_hash_values!( hash )
    end

    def deconstruct_from_bag_like(obj)
      obj.map { |entry|
        call( entry )
      }
    end

    def deconstruct_from_hash_like(obj)
      hash = HashWithIndifferentAccess.new(obj.to_h)
      deconstruct_hash_values!( hash )
    end

    def deconstruct_from_map_like(obj)
      hash = HashWIA.new.tap do |h|
        obj.each_pair do |k,v| ; h[k] = v ; end
      end
      deconstruct_hash_values!( hash )
    end

    def deconstruct_hash_values!(hash)
      hash.each_pair do |k,v|
        dv = call( v )
        hash[k] = dv unless dv.equal?( v )
      end
      hash
    end
  end

end
