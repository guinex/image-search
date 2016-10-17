require 'test_helper'

class ImageSearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image_search = image_searches(:one)
  end

  test "should get index" do
    get image_searches_url
    assert_response :success
  end

  test "should get new" do
    get new_image_search_url
    assert_response :success
  end

  test "should create image_search" do
    assert_difference('ImageSearch.count') do
      post image_searches_url, params: { image_search: {  } }
    end

    assert_redirected_to image_search_url(ImageSearch.last)
  end

  test "should show image_search" do
    get image_search_url(@image_search)
    assert_response :success
  end

  test "should get edit" do
    get edit_image_search_url(@image_search)
    assert_response :success
  end

  test "should update image_search" do
    patch image_search_url(@image_search), params: { image_search: {  } }
    assert_redirected_to image_search_url(@image_search)
  end

  test "should destroy image_search" do
    assert_difference('ImageSearch.count', -1) do
      delete image_search_url(@image_search)
    end

    assert_redirected_to image_searches_url
  end
end
