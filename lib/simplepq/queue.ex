defmodule Simplepq.Queue do
  @moduledoc """
  Struct storing information about queue.
  """
  @enforce_keys [:file_path, :equeue]
  defstruct [:file_path, :equeue]
end
