defmodule ExDebugToolbar.Toolbar do
  alias ExDebugToolbar.Database.RequestRepo
  alias ExDebugToolbar.Data.Collection
  alias ExDebugToolbar.Request
  alias ExDebugToolbar.Toolbar.Macros
  require Macros

  def start_request(uuid) do
    :ok = RequestRepo.insert(%Request{
      pid: self(),
      uuid: uuid,
      created_at: NaiveDateTime.utc_now()
    })
  end

  def get_request, do: self() |> get_request()
  defdelegate get_request(id), to: RequestRepo, as: :get

  defdelegate get_all_requests, to: RequestRepo, as: :all

  def start_event(name) do
    add_data(:timeline, {:start_event, name})
  end

  def finish_event(name, opts \\ []) do
    add_data(:timeline, {:finish_event, name, opts[:duration]})
  end

  def record_event(name, func) do
    start_event(name)
    result = func.()
    finish_event(name)
    result
  end

  def add_finished_event(name, duration) do
    add_data(:timeline, {:add_finished_event, name, duration})
  end

  def add_data(id \\ self(), key, data) do
    Macros.if_enabled do: do_add_data(id, key, data)
  end

  defp do_add_data(id, key, data) do
    if Map.has_key?(%Request{}, key) do
      :ok = RequestRepo.update(id, &update_request(&1, key, data))
    else
      {:error, :undefined_collection}
    end
  end

  defp update_request(%Request{} = request, key, data) do
    request |> Map.get(key) |> Collection.add(data) |> (&Map.put(request, key, &1)).()
  end
end
