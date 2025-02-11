# frozen_string_literal: true

require "spec_helper"

module ThreadUnsafe
  RSpec.describe ClassCounter do
    let(:counter) { described_class.new }
    let(:threads) { [] }
    let(:loops) { 10 }
    let(:iterations) { 1000 }
    let(:safely) { false }

    before { counter.reset }

    before do
      loops.times do
        threads << Thread.new do
          iterations.times { counter.increment(safely: safely) }
        end
      end

      threads.each(&:join)
    end

    it "should have ten threads" do
      expect(threads.size).to eq(loops)
    end

    describe "when not using mutex" do
      it "the counter is less than its supposed to be" do
        expect(counter.count).to be < (loops * iterations)
      end

      it "the counter is greater than number of iterations" do
        expect(counter.count).to be >= iterations
      end

      it "the counter is less than number of iterations x loops" do
        expect(counter.count).not_to eq(iterations * loops)
      end
    end

    describe "with the mutex" do
      let(:safely) { true }

      it "the counter is exactly the product of loops & iterations" do
        expect(counter.count).to eq(loops * iterations)
      end
    end
  end
end
