require 'spec_helper'
require 'oanda_bank'

describe Money::Bank::OANDA do

  context "Normal operation" do

    before(:each) do
      VCR.use_cassette('oanda_cassette') do
        @bank = Money::Bank::OANDA.new("554776", ENV['OANDA_ACCESS_TOKEN'])
        @bank.update_rates!
      end
    end

    it "Gives the correct rate for a tradeable instrument" do
      expect(@bank.exchange_with(Money.new(10000, "USD"), "CAD")).to eq(Money.new(10912, "CAD"))
    end

    it "Gives the correct rate for a a non-tradeable instrument reachable through USD" do
      expect(@bank.exchange_with(Money.new(10000, "CAD"), "SEK")).to eq(Money.new(62751, "SEK"))
    end

    it "automatically refreshes expired rates" do
      expect(@bank.exchange_with(Money.new(10000, "USD"), "CAD")).to eq(Money.new(10912, "CAD"))
      @bank.ttl_in_seconds = 0.2
      sleep 0.3
      VCR.use_cassette('oanda_cassette_2') do
        expect(@bank.exchange_with(Money.new(10000, "USD"), "CAD")).to eq(Money.new(10915, "CAD"))
      end
    end
  end

  context "Error handling" do

    it "Throws error on unknown rate" do
      VCR.use_cassette('oanda_cassette') do
        @bank = Money::Bank::OANDA.new("554776", ENV['OANDA_ACCESS_TOKEN'])
        @bank.update_rates!
      end
      expect{@bank.exchange_with(Money.new(10000, "USD"), "RON")}.to raise_error(Money::Bank::UnknownRate)
    end

    it "Throws error on bad response from OANDA" do
      VCR.use_cassette('oanda_cassette_error') do
        @bank = Money::Bank::OANDA.new("554776", "fake_access_token")
        expect{@bank.update_rates!}.to raise_error(Money::Bank::OANDA::FetchError)
      end
    end

  end

end
