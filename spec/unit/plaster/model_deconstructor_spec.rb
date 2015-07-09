require 'spec_helper'
require 'virtus'
require 'set'

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
          expect( subject.call('abc'  ) ).to eq('abc'  )
          expect( subject.call( 123   ) ).to eq( 123   )
          expect( subject.call( nil   ) ).to eq( nil   )
          expect( subject.call( true  ) ).to eq( true  )
          expect( subject.call( false ) ).to eq( false )
          expect( subject.call( 1..3  ) ).to eq( 1..3  )
        end

        it "returns the given object when it is a Time" do
          # Easily confused with a collection since it responds to #to_a.
          time_obj = Time.new
          expect( subject.call( time_obj ) ).to equal( time_obj )
        end

        it "returns the result of sending #model_deconstruct to a thus-responding object" do
          deconstructable_thing = double(
            :deconstructable_thing,
            model_deconstruct: :deconstruction_result
          )

          data = subject.call( deconstructable_thing )

          expect( data ).to eq( :deconstruction_result )
        end

        it "returns an independent, unfrozen copy of a flat HashWithIndifferentAccess" do
          original = HashWIA.new(a: 1, b: 2).freeze
          data = subject.call( original )
          expect( data ).to eq( original )
          data[:a] = 99
          expect( original ).to eq( HashWIA.new(a: 1, b: 2) )
        end

        it "returns a hash map with indifferent access for a flat Hash" do
          data = subject.call( {animal: 'goat', legs: 4} )
          expect( data[:animal ] ).to eq('goat')
          expect( data['animal'] ).to eq('goat')
          expect( data['legs'  ] ).to eq( 4    )
        end

        it "returns a hash map with indifferent access for a flat Struct model instance" do
          vehicle_class = Struct.new(:type, :wheels)
          vehicle = vehicle_class.new('tricycle', 3)
          data = subject.call( vehicle )
          expect( data ).to eq( HashWIA.new(type: 'tricycle', wheels: 3) )
        end

        it "returns a hash map with indifferent access for a flat Virtus model instance" do
          obj = VirtusFooBar.new(foo: 123, bar: 'xyz')
          expect( subject.call(obj) ).to eq( HashWIA.new(foo: 123, bar: 'xyz') )
        end

        it "returns a hash map for a map-analogue having a minimal #each_pair implementation" do
          klass = Class.new do
            def values ; end
            def [] ; end

            def each_pair
              yield [:key_a, 'aaa']
              yield [:key_b, 'bbb']
            end
          end

          object = klass.new
          expect( subject.call(object) ).to eq( HashWIA.new(key_a: 'aaa', key_b: 'bbb') )
        end

        it "returns an independent, unfrozen copy of a flat array" do
          original = ['abc', 123].freeze
          data = subject.call( original )
          expect( data ).to eq( original )
          data << 'x'
          expect( original ).to eq( ['abc', 123] )
        end

        it "returns an array of the entries from a set" do
          entries = ['abc', 'def', 'ghi']
          original = Set.new( entries )
          data = subject.call( original )
          expect( data.class ).to eq( Array )
          expect( data ).to match_array( entries )
        end

        it "deconstructs struct-data in hash values" do
          klass = Struct.new(:x, :y)
          original = {
            one: klass.new(1, 2),
            two: klass.new(3, 4)
          }
          data = subject.call( original )

          expect( data ).to eq( HashWIA.new(
            one: HashWIA.new(x: 1, y: 2),
            two: HashWIA.new(x: 3, y: 4)
          ) )
        end

        it "deconstructs struct-data in struct members" do
          class_a = Struct.new(:one, :two)
          class_b = Struct.new(:x, :y)

          original = class_a.new(
            class_b.new(1, 2),
            class_b.new(3, 4)
          )
          data = subject.call( original )

          expect( data ).to eq( HashWIA.new(
            one: HashWIA.new(x: 1, y: 2),
            two: HashWIA.new(x: 3, y: 4)
          ) )
        end

        it "deconstructs set-data in hash values" do
          klass = Struct.new(:x, :y)
          original = {
            one: Set.new( %w[a b] ),
            two: Set.new( %w[c d] )
          }
          data = subject.call( original )

          expect( data.length ).to eq(2)

          expect( data[:one] ).to be_kind_of( Array )
          expect( data[:one] ).to match_array( %w[a b] )

          expect( data[:two] ).to be_kind_of( Array )
          expect( data[:two] ).to match_array( %w[c d] )
        end

        it "deconstructs set-data in struct members" do
          klass = Struct.new(:one, :two)

          original = klass.new(
            Set.new( %w[a b] ),
            Set.new( %w[c d] )
          )
          data = subject.call( original )

          expect( data.length ).to eq(2)

          expect( data[:one] ).to be_kind_of( Array )
          expect( data[:one] ).to match_array( %w[a b] )

          expect( data[:two] ).to be_kind_of( Array )
          expect( data[:two] ).to match_array( %w[c d] )
        end

        it "deconstructs struct-data in collection members" do
          klass = Struct.new(:x, :y)
          original = [
            klass.new(1, 2),
            klass.new(3, 4)
          ]
          data = subject.call( original )

          expect( data ).to eq( [
            HashWIA.new( x: 1, y: 2 ),
            HashWIA.new( x: 3, y: 4 )
          ] )
        end
      end

    end

  end
end
