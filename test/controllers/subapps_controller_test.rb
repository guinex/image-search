require 'test_helper'

class SubappsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subapp = subapps(:one)
  end

  test "should get index" do
    get subapps_url
    assert_response :success
  end

  test "should get new" do
    get new_subapp_url
    assert_response :success
  end

  test "should create subapp" do
    assert_difference('Subapp.count') do
      post subapps_url, params: { subapp: {  } }
    end

    assert_redirected_to subapp_url(Subapp.last)
  end

  test "should show subapp" do
    get subapp_url(@subapp)
    assert_response :success
  end

  test "should get edit" do
    get edit_subapp_url(@subapp)
    assert_response :success
  end

  test "should update subapp" do
    patch subapp_url(@subapp), params: { subapp: {  } }
    assert_redirected_to subapp_url(@subapp)
  end

  test "should destroy subapp" do
    assert_difference('Subapp.count', -1) do
      delete subapp_url(@subapp)
    end

    assert_redirected_to subapps_url
  end
end
