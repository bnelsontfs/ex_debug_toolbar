defmodule ExDebugToolbar.Collector.InstrumentationCollectorTest do
  use ExDebugToolbar.CollectorCase, async: false
  alias ExDebugToolbar.Collector.InstrumentationCollector, as: Collector

  describe "ex_debug_toolbar"  do
    test "it starts request on ex_debug_toolbar start" do
      conn = %Plug.Conn{} |> Plug.Conn.put_private(:request_id, @request_id)
      Collector.ex_debug_toolbar(:start, %{}, %{conn: conn})
      assert {:ok, request} = get_request(@request_id)
      assert request.uuid == @request_id
      assert request.pid == self()
      assert %NaiveDateTime{} = request.created_at
    end
  end

  describe "phoenix_controller_call"  do
    setup [:start_request]

    test "it records a phoenix controller event" do
      call_collector(&Collector.phoenix_controller_call/3, duration: 19)
      assert {:ok, request} = get_request(@request_id)
      event = find_event(request.timeline, "controller.call")
      assert event
      assert event.duration == 19
    end
  end

  describe "phoenix_controller_render"  do
    setup [:start_request]

    test "it records a phoenix render event" do
      call_collector(&Collector.phoenix_controller_render/3, duration: 7)
      assert {:ok, request} = get_request(@request_id)
      event = find_event(request.timeline, "controller.render")
      assert event
      assert event.duration == 7
    end
  end

  defp call_collector(function, opts) do
    opts = [context: %{}, duration: 0] |> Keyword.merge(opts)
    function.(:start, %{}, opts[:context])
    |> (&function.(:stop, opts[:duration], &1)).()
  end
end
