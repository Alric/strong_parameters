require 'test_helper'

class PetsController < ActionController::Base
  def scalar
    params.ensure(:pet)
    head :ok
  end

  def multiple_scalar
    params.ensure(:pet, :vet, :owner)
    head :ok
  end

  def chained_scalar
    params.ensure(:pet).ensure(:vet, :owner)
    head :ok
  end

  def nested
    params.ensure(:pet => :name)
    head :ok
  end

  def double_nested
    params.ensure(:pet => { :owner => :name })
    head :ok
  end

  def crazy_town
    params.ensure(:book, { :pet => { :owner => { :contact_info => :phone } } }).ensure(:magazine => [:price, :name])
    head :ok
  end
end

class ActionControllerEnsureParamsTest < ActionController::TestCase
  tests PetsController

  test "missing ensured scalar parameter will raise exception" do
    post :scalar, {}
    assert_response :bad_request

    post :scalar, { :one => 'two' }
    assert_response :bad_request
  end

  test "ensured scalar parameter will not raise exception when present" do
    post :scalar, { :pet => 'JoJo' }
    assert_response :ok
  end

  test "missing any ensured scalar parameter will raise exception" do
    post :multiple_scalar, { :pet => 'JoJo' }
    assert_response :bad_request
  end

  test "ensured array parameter will not raise exception when all present" do
    post :multiple_scalar, { :pet => 'JoJo', :vet => 'Doolittle', :owner => 'Suess' }
    assert_response :ok
  end

  test "missing any chained ensured scalar parameter will raise exception" do
    post :chained_scalar, { :pet => 'JoJo' }
    assert_response :bad_request
  end

  test "ensured chained parameter will not raise exception when all present" do
    post :chained_scalar, { :pet => 'JoJo', :vet => 'Doolittle', :owner => 'Suess' }
    assert_response :ok
  end

  test "missing ensured nested parameter will raise exception" do
    post :nested, { :dog => 'Toto' }
    assert_response :bad_request

    post :nested, { :pet => 'name' }
    assert_response :bad_request

    post :nested, { :pet => { :nick_name => 'JoJo' } }
    assert_response :bad_request
  end

  test "ensured nested parameter will not raise exception when all present" do
    post :nested, { :pet => { :name => 'Toto' } }
    assert_response :ok
  end
  test "missing ensured double nested parameter will raise exception" do
    post :double_nested, { :pet => { :owner => { :nick_name => 'Suess' } } }
    assert_response :bad_request
  end

  test "ensured double nested parameter will not raise exception when all present" do
    post :double_nested, { :pet => { :owner => { :name => 'Suess' } } }
    assert_response :ok
  end

  test "missing combination of ensured parameters will raise exception" do
    post :crazy_town, { :pet => 'Bob' }
    assert_response :bad_request

    post :crazy_town, { :pet => 'Bob', :book => '100 Years of Solitude', :magazine => 'HBR' }
    assert_response :bad_request
  end

  test "complex combination of ensured parameters will not raise exception when all present" do
    post :crazy_town, {
      :book => '100 Years of Solitude',
      :magazine => { :price => 5.99, name: 'Rolling Stone' },
      :other => 'thing',
      :pet => {
        :owner => {
          :contact_info => {
            :phone => '434-555-5555'
          }
        },
        :sister => 'Killah B'
      }
    }
    assert_response :ok
  end

  test "missing ensured parameters will be mentioned in the result" do
    post :scalar, { :dog => 'Benji' }
    assert_equal "Required parameter missing: pet", response.body

    post :nested, { :pet => { :nick_name => "JoJo" } }
    assert_equal "Required parameter missing: pet => name", response.body

    post :double_nested, { :pet => { :owner => "JoJo" } }
    assert_equal "Required parameter missing: pet => owner => name", response.body
  end

end
