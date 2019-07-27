require 'singleton'

class MyCountryLoader < Rails::Application
  include Singleton

  attr_reader :countries

  def initialize
    @countries = []
    all_props = []
    first_line = true
    IO.foreach('countries.csv') do |line|
      if first_line
        all_props = line.split(',')
        first_line = false
      else
        fields = line.split(',')
        country = {}
        for i in (0...all_props.length)
          country[ all_props[i] ] = fields[i]
        end
        @countries << country
      end
    end
  end
end

