require 'spec_helper'
require 'virtus'

module Plaster
  module ModelDeconstructorSpec

    class VirtusFooBar
      include Virtus.model
      attribute :foo, Object
      attribute :bar, String
    end

    describe ModelDeconstructor do
      subject{ described_class }

      describe "#call" do
        it "returns a simple value for a miscellaneous object" do
          expect( subject.call( 'abc' ) ).to eq( 'abc' )
          expect( subject.call(  123  ) ).to eq(  123  )
          expect( subject.call(  1..3 ) ).to eq(  1..3 )
        end

        it "returns the result of sending #model_deconstruct to a thus-responding object" do
          deconstructable_thing = double(
            :deconstructable_thing,
            model_deconstruct: :deconstruction_result
          )

          data = subject.call( deconstructable_thing )

          expect( data ).to eq( :deconstruction_result )
        end

        it "returns an independent, unfrozen copy of a hash with indifferent access" do
          original = HashWIA.new(a: 1, b: 2).freeze
          data = subject.call( original )
          expect( data ).to eq( original )
          data[:a] = 99
          expect( original ).to eq( HashWIA.new(a: 1, b: 2) )
        end

        it "returns a hash map with indifferent access for a flat hash" do
          data = subject.call( {animal: 'goat', legs: 4} )
          expect( data[ :animal  ] ).to eq('goat')
          expect( data[ 'animal' ] ).to eq('goat')
          expect( data[ 'legs'   ] ).to eq( 4    )
        end

        it "returns an array for a flat array" do
          data = subject.call( ['abc', 123] )
          expect( data ).to eq( ['abc', 123] )
        end

        it "returns a hash map with indifferent access for a flat struct" do
          vehicle_class = Struct.new(:type, :wheels)
          vehicle = vehicle_class.new('tricycle', 3)
          data = subject.call( vehicle )
          expect( data ).to eq( HashWIA.new(type: 'tricycle', wheels: 3) )
        end

        it "returns a hash map with indifferent access for a flat Virtus model" do
          obj = VirtusFooBar.new(foo: 123, bar: 'xyz')
          expect( subject.call(obj) ).to eq( HashWIA.new(foo: 123, bar: 'xyz') )
        end

        it "returns a hash map for an object with a minimal #each_pair implementation" do
          klass = Class.new do
            def each_pair
              yield [:key_a, 'aaa']
              yield [:key_b, 'bbb']
            end
          end
          object = klass.new
          expect( subject.call(object) ).to eq( HashWIA.new(key_a: 'aaa', key_b: 'bbb') )
        end
      end

    end

  end
end
