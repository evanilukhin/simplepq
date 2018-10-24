defmodule Simplepq do
  alias Simplepq.Queue
  @moduledoc """
  Simple queue that's stored on the disc.

  Warning! At this moment all functions don't handle case when the file don't exist. Errors can be raised.
  """

  @doc """
  Creates file on the filesystem and create Simplepq.Queue associated with this file.

  Returns `{:ok, queue}` in case of success, else {:error, :file.posix()}.
  """
  @spec create(String.t) :: {:ok, queue::Simplepq.Queue}  | {:error, :file.posix()}
  def create(file_path) when is_bitstring(file_path) do
    new_equeue = %Queue{file_path: file_path, equeue: {}}
    update_queue(new_equeue, :queue.new())
  end

  @doc """
  Opens queue from file `file_path`.

  Returns `{:ok, queue}` in case of success, or `{:error, :bad_file}` when file
  can not be converted to term or term is not .

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

  Returns `{:ok, queue}` if element added, else {:error, :file.posix()}.
  """
  @spec add(Simplepq.Queue, String.t) :: {:ok, queue::Simplepq.Queue} | {:error, :file.posix()}
  def add(%Simplepq.Queue{equeue: equeue} = queue, message) do
    equeue = :queue.in(message, equeue)
    update_queue(queue, equeue)
  end

  @doc """
  Reads first element from queue without removing.

  Returns `{:ok, message}` if element exists, or `{:error, :empty} when queue is empty`.
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
  Rejects first elemet from the the queue. This method don't return element and don't have
  special return for the case when queue is empty. It's just return
  this queue.

  Returns `{:ok, queue}` if element successfully rejected or queue is empty.
  Else {:error, reason} when caused problem on writing the file
  """
  @spec ack(Simplepq.Queue) :: {:ok, queue::Simplepq.Queue} | {:error, :file.posix()}
  def ack(%Queue{equeue: equeue} = queue) do
    {result , equeue} = :queue.out(equeue)
    case result do
      {:value, _} -> update_queue(queue, equeue)
      _ -> {:ok, queue}
    end
  end

  @doc """
  Take first element from the queue and place it in to the end of the queue.

  Returns `{:ok, queue}` if element successfully moved or queue is empty.
  Else {:error, reason} when caused problem on writing the file
  """
  @spec reject(Simplepq.Queue) :: {:ok, queue::Simplepq.Queue} | {:error, :file.posix()}
  def reject(%Queue{equeue: equeue} = queue) do
    {result , equeue} = :queue.out(equeue)
    case result do
      {:value, value} -> update_queue(queue, :queue.in(value, equeue))
      _ -> {:ok, queue}
    end
  end

  @doc """
  Return count elements in the queue.
  """
  @spec length(Simplepq.Queue) :: number
  def length(%Queue{equeue: equeue}) do
    :queue.len(equeue)
  end

  @spec update_queue(Simplepq.Queue, tuple) :: {:ok, queue::Simplepq.Queue} | {:error, :file.posix()}
  defp update_queue(%Queue{file_path: file_path} = queue, equeue) do
    case File.write(file_path, :erlang.term_to_binary(equeue)) do
      :ok -> {:ok, %{queue | equeue: equeue}}
      {:error, reason} -> {:error, reason}
    end
  end
end
