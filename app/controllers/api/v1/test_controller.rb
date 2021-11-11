class Api::V1::TestController < ApplicationController

  def index
    test = {
      'test' => "Ceci est la représentation d'un test!"
    }
    render json: test.to_json
  end
end
