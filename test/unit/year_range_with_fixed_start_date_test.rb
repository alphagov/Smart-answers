require_relative '../test_helper'

module SmartAnswer
  class YearRangeWithFixedStartDateTest < ActiveSupport::TestCase
    context 'with a tax year' do
      setup do
        @tax_year = YearRangeWithFixedStartDate.new("6 April")
      end

      context 'when tax year is built for specified year' do
        setup do
          @tax_year_2000 = @tax_year.starting_in(2000)
        end

        should 'begin on 6th April of the specified year' do
          assert_equal Date.parse('2000-04-06'), @tax_year_2000.begins_on
        end

        should 'end on 5th April of the following year' do
          assert_equal Date.parse('2001-04-05'), @tax_year_2000.ends_on
        end
      end

      context 'when tax year is built for a date on or after 6th April' do
        setup do
          @tax_year_2000 = @tax_year.including(Date.parse('2000-04-06'))
        end

        should 'begin on 6th April' do
          assert_equal Date.parse('2000-04-06'), @tax_year_2000.begins_on
        end

        should 'end on 5th April of the following calendar year' do
          assert_equal Date.parse('2001-04-05'), @tax_year_2000.ends_on
        end
      end

      context 'when tax year is built for a date before 6th April' do
        setup do
          @tax_year_1999 = @tax_year.including(Date.parse('2000-04-05'))
        end

        should 'begin on 6th April of the previous calendar year' do
          assert_equal Date.parse('1999-04-06'), @tax_year_1999.begins_on
        end

        should 'end on 5th April' do
          assert_equal Date.parse('2000-04-05'), @tax_year_1999.ends_on
        end
      end

      context 'when tax year is built for today' do
        setup do
          Timecop.freeze(Date.parse('2000-01-01'))
          @tax_year_1999 = @tax_year.current
        end

        teardown do
          Timecop.return
        end

        should 'begin on 6th April' do
          assert_equal Date.parse('1999-04-06'), @tax_year_1999.begins_on
        end

        should 'end on 5th April' do
          assert_equal Date.parse('2000-04-05'), @tax_year_1999.ends_on
        end
      end
    end
  end
end
