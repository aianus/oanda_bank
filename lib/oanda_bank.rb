require 'oauth2'
require 'money'
require 'bigdecimal'
require 'bigdecimal/util'

class Money
  module Bank
    class OANDA < VariableExchange

      # Raised when there is an unexpected error in extracting exchange rates
      # from OANDA
      class FetchError < StandardError; end

      INSTRUMENTS_URL = "https://api-fxtrade.oanda.com/v1/instruments"
      RATES_URL       = "https://api-fxtrade.oanda.com/v1/prices"

      # @return [Integer] Returns the Time To Live (TTL) in seconds.
      attr_reader :ttl_in_seconds

      # @return [Time] Returns the time when the rates expire.
      attr_reader :rates_expiration

      def initialize(account_id, access_token, opts={})
        @client = OAuth2::Client.new(nil, nil)
        @access_token = OAuth2::AccessToken.new(@client, access_token)
        @account_id = account_id
        @updating_mutex = Mutex.new
        setup
      end

      def update_rates!
        begin
          new_rates = fetch_rates
          @mutex.synchronize do
            @rates = new_rates
            refresh_rates_expiration!
          end
        rescue
          raise FetchError.new
        end
      end

      def get_rate(from, to, opts = {})
        expire_rates
        fn = Proc.new do
          straight_through = @rates[rate_key_for(from, to)]
          if straight_through
            straight_through
          else
            to_usd   = @rates[rate_key_for(from, 'USD')]
            from_usd = @rates[rate_key_for('USD', to)]
            if (to_usd && from_usd)
              to_usd * from_usd
            else
              nil
            end
          end
        end
        if opts[:without_mutex]
          fn.call
        else
          @mutex.synchronize { fn.call }
        end
      end

      def expire_rates
        if @ttl_in_seconds && @rates_expiration <= Time.now
          if @updating_mutex.try_lock
            begin
              update_rates!
              true
            ensure
              @updating_mutex.unlock
            end
          end
        else
          false
        end
      end

      ##
      # Set the Time To Live (TTL) in seconds.
      #
      # @param [Integer] the seconds between an expiration and another.
      def ttl_in_seconds=(value)
        @ttl_in_seconds = value
        refresh_rates_expiration! if ttl_in_seconds
      end

    protected

      def fetch_rates
        instruments = @access_token.get("#{INSTRUMENTS_URL}?accountId=#{@account_id}")
        instruments = JSON.parse(instruments.body)

        instrument_codes = instruments['instruments'].map do |instrument|
          instrument['instrument']
        end

        instruments_argument = instrument_codes.join('%2C')

        rates = @access_token.get("#{RATES_URL}?instruments=#{instruments_argument}")
        rates = JSON.parse(rates.body)
        rates = rates['prices']

        result = {}
        rates.each do |rate|
          match = /(?<base>[A-Z0-9]+)_(?<quote>[A-Z0-9]+)/.match(rate['instrument'])

          if !match
            next
          end

          from  = match[:base].upcase
          to    = match[:quote].upcase

          if !Money::Currency.find(from) || !Money::Currency.find(to)
            next
          end

          result[rate_key_for(from, to)] = rate['bid'].to_d
          result[rate_key_for(to, from)] = (1/rate['ask']).to_d
        end
        result
      end

    private

      def refresh_rates_expiration!
        if @ttl_in_seconds
          @rates_expiration = Time.now + @ttl_in_seconds
        end
      end

    end # /OANDA
  end # /Bank
end # /Money
