# frozen_string_literal: true

require "spec_helper"

module ThreadUnsafe
  RSpec.describe ClassCounter do
    let(:instance) { described_class.new }
    let(:initial) { 10 }

    before { instance.increment(by: initial) }

    it "has a count of initial value 10" do
      expect(instance.count).to eq(initial)
    end

    describe "when incrementing in a single thread" do
      it "increments the counter to expected value" do
        expect(instance.count).to eq(initial)
      end
    end
  end
end
