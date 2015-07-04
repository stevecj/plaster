require 'spec_helper'
require 'virtus'

module Plaster
  module PlasterSpec

    class VirtusFooBar
      include Virtus.model
      attribute :foo, Object
      attribute :bar, String
    end

    describe Plaster do

      it 'has a version number' do
        expect(Plaster::VERSION).not_to be nil
      end

      describe "#deconstruct" do
        it "returns a simple value for a miscellaneous object" do
          expect( subject.deconstruct( 'abc' ) ).to eq( 'abc' )
          expect( subject.deconstruct(  123  ) ).to eq(  123  )
          expect( subject.deconstruct(  1..3 ) ).to eq(  1..3 )
        end

        it "returns the result of sending #model_deconstruct to a thus-responding object" do
          deconstructable_thing = double(
            :deconstructable_thing,
            model_deconstruct: :deconstruction_result
          )

          data = subject.deconstruct( deconstructable_thing )

          expect( data ).to eq( :deconstruction_result )
        end

        it "returns an independent, unfrozen copy of a hash with indifferent access" do
          original = HashWIA.new(a: 1, b: 2).freeze
          data = subject.deconstruct( original )
          expect( data ).to eq( original )
          data[:a] = 99
          expect( original ).to eq( HashWIA.new(a: 1, b: 2) )
        end

        it "returns a hash map with indifferent access for a flat hash" do
          data = subject.deconstruct( {animal: 'goat', legs: 4} )
          expect( data[ :animal  ] ).to eq('goat')
          expect( data[ 'animal' ] ).to eq('goat')
          expect( data[ 'legs'   ] ).to eq( 4    )
        end

        it "returns an array for a flat array" do
          data = subject.deconstruct( ['abc', 123] )
          expect( data ).to eq( ['abc', 123] )
        end

        it "returns a hash map with indifferent access for a flat struct" do
          vehicle_class = Struct.new(:type, :wheels)
          vehicle = vehicle_class.new('tricycle', 3)
          data = subject.deconstruct( vehicle )
          expect( data ).to eq( HashWIA.new(type: 'tricycle', wheels: 3) )
        end

        it "returns a hash map with indifferent access for a flat Virtus model" do
          obj = VirtusFooBar.new(foo: 123, bar: 'xyz')
          expect( subject.deconstruct(obj) ).to eq( HashWIA.new(foo: 123, bar: 'xyz') )
        end

        it "returns a hash map for an object with a minimal #each_pair implementation" do
          klass = Class.new do
            def each_pair
              yield [:key_a, 'aaa']
              yield [:key_b, 'bbb']
            end
          end
          object = klass.new
          expect( subject.deconstruct(object) ).to eq( HashWIA.new(key_a: 'aaa', key_b: 'bbb') )
        end
      end

    end

  end
end
