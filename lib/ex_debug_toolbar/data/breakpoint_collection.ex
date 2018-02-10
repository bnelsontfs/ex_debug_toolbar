alias ExDebugToolbar.Data.Collection
alias ExDebugToolbar.Breakpoint

defmodule ExDebugToolbar.Data.BreakpointCollection do
  @moduledoc false

  defstruct [count: 0, entries: %{}]

  def find(breakpoints, id) do
    case Map.fetch(breakpoints.entries, id) do
      :error -> {:error, :not_found}
      {:ok, breakpoint} -> {:ok, breakpoint}
    end
  end
end

alias ExDebugToolbar.Data.BreakpointCollection

defimpl Collection, for: BreakpointCollection do
  @breakpoints_limit ExDebugToolbar.Config.get_breakpoints_limit()

  def add(%{count: @breakpoints_limit} = breakpoints, %Breakpoint{}), do: breakpoints
  def add(%{count: count} = breakpoints, %Breakpoint{id: nil} = breakpoint) do
    add(breakpoints, %{breakpoint | id: to_string(count)})
  end
  def add(breakpoints, %Breakpoint{} = breakpoint) do
    %{
      breakpoints |
      entries: Map.put(breakpoints.entries, breakpoint.id, breakpoint),
      count: breakpoints.count + 1
    }
  end
end
