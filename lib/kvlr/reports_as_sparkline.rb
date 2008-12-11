module Kvlr #:nodoc:

  module ReportsAsSparkline

    def self.included(base) #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods

      # Generates a report on a model. The report can then be executed via <name>_report
      # 
      # ==== Parameters
      #
      # * <tt>name</tt> - The name of the report, defines the name of the generated report method (<name>_report)
      #
      # ==== Options
      #
      # * <tt>:date_column_name</tt> - The name of the date column on that the records are aggregated
      # * <tt>:value_column_name</tt> - The name of the column that holds the value to sum for aggregation :sum
      # * <tt>:aggregation</tt> - The aggregation to use (either :count or :sum); when using :sum, :value_column_name must also be specified
      # * <tt>:grouping</tt> - The period records are grouped on (:hour, :day, :week, :month)
      # * <tt>:limit</tt> - The number of periods to get (see :grouping)
      # * <tt>:conditions</tt> - Conditions like in ActiveRecord::Base#find; only records that match there conditions are reported on
      #
      # ==== Examples
      #
      #  class Game < ActiveRecord::Base
      #    report_as_sparkline :games_per_day
      #    report_as_sparkline :games_played_total, :cumulate => true
      #  end
      #  class User < ActiveRecord::Base
      #    report_as_sparkline :registrations, :operation => :count
      #    report_as_sparkline :activations, :date_column_name => :activated_at, :operation => :count
      #    report_as_sparkline :total_users_report, :cumulate => true
      #    report_as_sparkline :rake, :aggregation => :sum, :value_column_name => :profile_visits
      #  end
      def report_as_sparkline(name, options = {})
        (class << self; self; end).instance_eval do
          define_method "#{name.to_s}_report".to_sym do |*args|
            if options.delete(:cumulate)
              report = Kvlr::ReportsAsSparkline::CumulatedReport.new(self, name, options)
            else
              report = Kvlr::ReportsAsSparkline::Report.new(self, name, options)
            end
            raise ArgumentError.new unless args.length == 0 || (args.length == 1 && args[0].is_a?(Hash))
            report.run(args.length == 0 ? {} : args[0])
          end
        end
      end

    end

  end

end
