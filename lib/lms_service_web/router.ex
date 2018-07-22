defmodule LmsServiceWeb.Router do
  use LmsServiceWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", LmsServiceWeb do
    pipe_through(:api)
    get("/users/:id/leaves", LeavesController, :get_leaves)
    get("/users/:id/notifications", LeavesController, :get_notifications)
    post("/users/:id/applyLeave", LeavesController, :apply_leave)
    post("/users/:id/approveLeave", LeavesController, :approve_leave)
    post("/users/:id/rejectLeave", LeavesController, :reject_leave)
  end
end
