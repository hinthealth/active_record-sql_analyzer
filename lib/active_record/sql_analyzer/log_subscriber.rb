require 'active_support/log_subscriber'

module ActiveRecord
  module SqlAnalyzer
    class LogSubscriber < ActiveSupport::LogSubscriber
      QueryAnalyzerCall = Struct.new(:sql, :caller, :duration)

      def sql(event)
        # p event
        # info "#{event.payload[:name]} (#{event.duration}) #{event.payload[:sql]}"

        sql = event.payload[:sql]
        duration = event.duration

        return super unless SqlAnalyzer.config

        safe_sql = nil
        query_analyzer_call = nil

        # Record "full" transactions (see below for more information about "full")
        # if @_query_analyzer_private_in_transaction
        #   if @_query_analyzer_private_record_transaction
        #     safe_sql ||= sql.encode(Encoding::UTF_8, invalid: :replace, undef: :replace)
        #     query_analyzer_call ||= QueryAnalyzerCall.new(safe_sql, caller, duration)
        #     @_query_analyzer_private_transaction_queue << query_analyzer_call
        #   end
        # end

        # Record interesting queries
        SqlAnalyzer.config[:analyzers].each do |analyzer|
          if SqlAnalyzer.config[:should_log_sample_proc].call(analyzer[:name])
            # This is here rather than above intentionally.
            # We assume we're not going to be analyzing 100% of queries and want to only re-encode
            # when it's actually relevant.

            # p '----', sql, duration, '------'
            safe_sql ||= sql.encode(Encoding::UTF_8, invalid: :replace, undef: :replace)

            query_analyzer_call ||= QueryAnalyzerCall.new(safe_sql, caller, duration)

            if safe_sql =~ analyzer[:table_regex]
              SqlAnalyzer.background_processor <<
                _query_analyzer_private_query_stanza([query_analyzer_call], analyzer)
            end
          end
        end
      end

      private

      # Helper method to construct the event for a query or transaction.
      # safe_sql [string]: SQL statement or combined SQL statement for transaction
      # calls: A list of QueryAnalyzerCall objects to be turned into call hashes
      def _query_analyzer_private_query_stanza(calls, analyzer)
        {
          # Calls are of the format {sql: String, caller: String}
          calls: calls.map(&:to_h),
          logger: analyzer[:logger_instance],
          tag: Thread.current[:_ar_analyzer_tag],
          request_path: Thread.current[:_ar_analyzer_request_path],
        }
      end

    end
  end
end
