require 'spec_helper'

module Plaster

  describe Plaster do
    it 'has a version number' do
      expect(Plaster::VERSION).not_to be nil
    end

    describe "::deconstruct" do
      it "deconstructs a model" do
        model_class = Struct.new(:foo, :bar)
        model_obj = model_class.new(1, 2)

        expect( subject.deconstruct(model_obj) ).
          to eq( HashWIA.new(foo: 1, bar: 2) )
      end
    end

    describe '::[]' do
      it "returns WrappingList when called with no arguments" do
        expect( subject[] ).to eq( WrappingList )
      end
    end
  end

end
