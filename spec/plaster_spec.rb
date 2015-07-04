require 'spec_helper'
require 'virtus'

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
      it "returns a simple value for a simple value" do
        expect( subject.deconstruct( 'abc' ) ).to eq( 'abc' )
        expect( subject.deconstruct(  123  ) ).to eq(  123  )
        expect( subject.deconstruct(  1..3 ) ).to eq(  1..3 )
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
        expect( data ).to eq( HashWithIndifferentAccess.new(type: 'tricycle', wheels: 3) )
      end

      it "returns a hash map with indifferent access for a flat Virtus model" do
        obj = VirtusFooBar.new(foo: 123, bar: 'xyz')
        expect( subject.deconstruct(obj) ).to eq( HashWithIndifferentAccess.new(foo: 123, bar: 'xyz') )
      end
    end

  end
end
