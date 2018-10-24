defmodule SimplepqTest do
  use ExUnit.Case

  # Warning! This tests work with filesystem. Ensure that's you have permissions
  # for reading and writing in the directory where you running the tests.

  describe "Simplepq.create/1" do
    setup do
      File.rm('tmp/test.queue')
      :ok
    end

    test "create the file and return tuple with new Simplepq.Queue" do
      file_path = "tmp/test.queue"
      try do
        assert {:ok, %Simplepq.Queue{equeue: {[], []}, file_path: ^file_path}} = Simplepq.create(file_path)
        assert File.exists?(file_path)
        assert {[], []} = file_path |> File.read! |> :erlang.binary_to_term()
      after
        File.rm(file_path)
      end
    end
  end

  describe "Simplepq.open/1" do
    test "open the right empty queue file" do
      file_path = 'test/fixtures/good_empty.queue'
      assert {:ok, %Simplepq.Queue{equeue: {[], []}, file_path: ^file_path}} = Simplepq.open(file_path)
    end

    test "open the right non empty queue file" do
      file_path = 'test/fixtures/good.queue'
      assert {:ok, %Simplepq.Queue{equeue: {[5, 4, 3, 2], [1]}, file_path: ^file_path}} = Simplepq.open(file_path)
    end

    test "open the bad file" do
      file_path = 'test/fixtures/bad.queue'
      assert {:error, :bad_file} = Simplepq.open(file_path)
    end
  end

  describe "Simplepq.add/2" do
    test "add message to empty queue" do
      file_path = "tmp/empty.queue"
      File.rm(file_path)

      {:ok, queue} = Simplepq.create(file_path)

      message = "message"
      try do
        assert {:ok, %Simplepq.Queue{equeue: {[^message], []}, file_path: ^file_path}} = Simplepq.add(queue, message)
        assert {[^message], []} = file_path |> File.read! |> :erlang.binary_to_term()
      after
        File.rm(file_path)
      end
    end
  end

  describe "Simplepq.get/1" do
    test "get first element from the empty queue" do
      file_path = 'test/fixtures/good_empty.queue'
      {:ok, queue} = Simplepq.open(file_path)
      assert {:error, :empty} = Simplepq.get(queue)
    end

    test "get first element from the non empty queue" do
      file_path = 'test/fixtures/good.queue'
      {:ok, queue} = Simplepq.open(file_path)
      assert {:ok, 1} = Simplepq.get(queue)
    end
  end

  describe "Simplepq.reject/1" do
    test "reject from the empty queue"do
      file_path = "tmp/empty.queue"
      File.rm(file_path)

      {:ok, queue} = Simplepq.create(file_path)

      try do
        assert {:ok, %Simplepq.Queue{file_path: ^file_path, equeue: {[], []}}} =
          Simplepq.reject(queue)
      after
        File.rm(file_path)
      end
    end

    test "reject from the non empty queue" do
      file_path = "tmp/not_empty.queue"
      File.rm(file_path)

      {:ok, queue} = Simplepq.create(file_path)
      {:ok, queue} = Simplepq.add(queue, 1)
      {:ok, queue} = Simplepq.add(queue, 2)

      try do
        assert {:ok, %Simplepq.Queue{equeue: {[], [2]}, file_path: ^file_path}} =
          Simplepq.reject(queue)
        assert {[], [2]} = file_path |> File.read! |> :erlang.binary_to_term()
      after
        File.rm(file_path)
      end
    end
  end

  describe "Simplepq.length/1" do
    test "empty queue length" do
      file_path = 'test/fixtures/good_empty.queue'
      {:ok, queue} = Simplepq.open(file_path)
      assert Simplepq.length(queue) == 0
    end

    test "not empty queue lenght" do
      file_path = 'test/fixtures/good.queue'
      {:ok, queue} = Simplepq.open(file_path)
      assert Simplepq.length(queue) == 5
    end
  end
end
