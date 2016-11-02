require 'test_helper'

class ManageCatalogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @manage_catalog = manage_catalogs(:one)
  end

  test "should get index" do
    get manage_catalogs_url
    assert_response :success
  end

  test "should get new" do
    get new_manage_catalog_url
    assert_response :success
  end

  test "should create manage_catalog" do
    assert_difference('ManageCatalog.count') do
      post manage_catalogs_url, params: { manage_catalog: {  } }
    end

    assert_redirected_to manage_catalog_url(ManageCatalog.last)
  end

  test "should show manage_catalog" do
    get manage_catalog_url(@manage_catalog)
    assert_response :success
  end

  test "should get edit" do
    get edit_manage_catalog_url(@manage_catalog)
    assert_response :success
  end

  test "should update manage_catalog" do
    patch manage_catalog_url(@manage_catalog), params: { manage_catalog: {  } }
    assert_redirected_to manage_catalog_url(@manage_catalog)
  end

  test "should destroy manage_catalog" do
    assert_difference('ManageCatalog.count', -1) do
      delete manage_catalog_url(@manage_catalog)
    end

    assert_redirected_to manage_catalogs_url
  end
end
