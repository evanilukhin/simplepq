# Simplepq
Simple, persistent queue

There is a simple library that gives you a possibility to create the queues and
to interact with them. Queues are stored as not encrypted files on the filesystem. It is slow but really robust.
because it's rewrite the associated file after an every change.

[Documentation for Simplepq is available online](http://hexdocs.pm/simplepq/readme.html).

## Installation
Just add this to your `mix.exs` dependencies:
```elixir
  {:simplepq, "~> 0.2.0"}
```

## Basic Usage
Base operations:
``` elixir
iex(1)> {:ok, queue} = Simplepq.create("new.queue")
{:ok, %Simplepq.Queue{equeue: {[], []}, file_path: "new.queue"}}
iex(2)> {:ok, queue} = Simplepq.add(queue, "new_message")
{:ok, %Simplepq.Queue{equeue: {["new_message"], []}, file_path: "new.queue"}}
iex(3)> {:ok, queue} = Simplepq.add(queue, "another_new_message")
{:ok,
 %Simplepq.Queue{
   equeue: {["another_new_message"], ["new_message"]},
   file_path: "new.queue"
 }}
iex(4)> {:ok, first_message} = Simplepq.get(queue)
{:ok, "new_message"}
iex(5)> Simplepq.length(queue)                   
2
```
Ack and reject:
``` elixir
iex(1)> {:ok, old_queue} = Simplepq.open("old.queue")
{:ok, %Simplepq.Queue{equeue: {[3, 2], [1]}, file_path: "old.queue"}}
iex(2)> {:ok, old_queue} = Simplepq.reject(old_queue)
{:ok, %Simplepq.Queue{equeue: {[1, 3], [2]}, file_path: "old.queue"}}
iex(3)> Simplepq.get(old_queue)                      
{:ok, 2}
iex(4)> {:ok, old_queue} = Simplepq.ack(old_queue)   
{:ok, %Simplepq.Queue{equeue: {[1], [3]}, file_path: "old.queue"}}
```

## Plans

- [x] 100% coverage🎉 (I know, that's means only the 100% coverage, not 100% working code)
- [ ] Methods with `!`, that will be raise exceptions after fails
