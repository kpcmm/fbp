class EntriesControllerTest < ActionController::TestCase
  test "should get index" do
    get(:show, {'id' => "3605153", 'user_id' => '644829261'})
    # assert_response :success
    # assert_not_nil assigns(:picks)
  end
end