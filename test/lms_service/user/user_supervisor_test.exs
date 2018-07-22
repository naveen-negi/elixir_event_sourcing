defmodule LmsService.User.SupervisorTest do
  use LmsService.DataCase, async: true
  alias LmsService.User.Supervisor

  test "should be able to start user process" do
    assert {:ok, pid} = Supervisor.start_user("some random string ")
  end
end
