class CountriesController < ApplicationController
  def index
    props = params[:props].split('/')
    if props[-1] == ''
      props.pop
    end
    render json: get_country_props(props)
  end

  private
  def get_country_props(props)
    result = []
    for country in MyCountryLoader.instance.countries
      item = {}
      for prop in country.keys
        if props.include?(prop)
          item[prop] = country[prop]
        end
      end
      if not item.empty?
        result << item
      end
    end
    return result
  end
end
