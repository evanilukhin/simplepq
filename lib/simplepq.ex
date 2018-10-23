defmodule Simplepq do
  alias Simplepq.Queue
  @moduledoc """
  Simple queue that's stored on the disc.
  ## Usage:
  ```elixir
    {:ok, new_queue} = Simplepq.create("new.queue")
    {:ok, old_queue} = Simplepq.open("old.queue")
    {:ok, old_message} = Simplepq.get(old_queue)
    {:ok, new_queue} = Simplepq.add(new_queue, old_message)
    {:ok, old_queue} = Simplepq.reject(old_queue)
  ```
  """

  @doc """
  Creates file on the filesystem if  and create Simplepq.Queue associated with this file.

  Returns `{:ok, Simplepq.Queue}` if all right.

  ## Examples

      iex> Simplepq.create("/home/queue.simplepq")
      :ok

  """
  @spec create(String.t) :: {:ok, queue::Simplepq.Queue}  | {:error, :file.posix()}
  def create(file_path) when is_bitstring(file_path) do
    new_equeue = %Queue{file_path: file_path, equeue: {}}
    update_queue(new_equeue, :queue.new())
  end

  @doc """
  Opens queue from file `filename`.

  Returns `{:ok, Simplepq.Queue}` if all right.

  ## Examples

      iex> Simplepq.open("file.queue")
      {:ok, %Simplepq.Queue{file: "/dir/with/queues/file.queue"}}

  """
  def open(file_path) do
    binary_queue = File.read!(file_path)
    try do
      # Can raised ArgumentError
      term_from_file = :erlang.binary_to_term(binary_queue)

      if :queue.is_queue(term_from_file) do
        {:ok, %Queue{file_path: file_path, equeue: term_from_file}}
      else
        {:error, :bad_file}
      end
    rescue
      _ in ArgumentError -> {:error, :bad_file}
    end
  end

  @doc """
  Adds elemet to the end of queue.

  Returns `{:ok, queue}` if element added.

  ## Examples

      iex> Simplepq.add(queue, "message")
      {:ok, queue}

  """
  @spec add(Simplepq.Queue, String.t) :: {:ok, queue::Simplepq.Queue} | {:error, :file.posix()}
  def add(%Simplepq.Queue{equeue: equeue} = queue, message) do
    equeue = :queue.in(message, equeue)
    update_queue(queue, equeue)
  end

  @doc """
  Reads first element from queue without removing.

  Returns `{:ok, message}` if element exists.

  ## Examples

      iex> Simplepq.get(queue)
      {:ok, "first queue message"}

  """
  @spec get(Simplepq.Queue) :: {:ok, message::String.t} | {:error, :empty}
  def get(%Queue{equeue: equeue}) do
    if :queue.is_empty(equeue) do
      {:error, :empty}
    else
      {:ok, :queue.get(equeue)}
    end
  end

  @doc """
  Rejects first elemet from the the queue. This method don't return elemnt and don't have
  special return for the case when queue is empty. It's just return
  this queue.

  Returns `{:ok, queue}` if element successfully rejected.
  Else {:error, reason} when caused problem when writing the file

  ## Examples

      iex> Simplepq.reject(queue)
      {:ok, queue}

  """
  @spec reject(Simplepq.Queue) :: {:ok, queue::Simplepq.Queue} | {:error, :file.posix()}
  def reject(%Queue{equeue: equeue} = queue) do
    {result , equeue} = :queue.out(equeue)
    case result do
      {:value, _} -> update_queue(queue, equeue)
      _ -> {:ok, queue}
    end
  end

  @doc """
  Return count elemens in the queue.

  ## Examples

      iex> Simplepq.length(queue)
      9

  """
  @spec length(Simplepq.Queue) :: number
  def length(%Queue{equeue: equeue}) do
    :queue.len(equeue)
  end

  defp update_queue(%Queue{file_path: file_path} = queue, equeue) do
    case File.write(file_path, :erlang.term_to_binary(equeue)) do
      :ok -> {:ok, %{queue | equeue: equeue}}
      {:error, reason} -> {:error, reason}
    end
  end
end
