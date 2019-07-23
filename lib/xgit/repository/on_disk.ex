defmodule Xgit.Repository.OnDisk do
  @moduledoc ~S"""
  Implementation of `Xgit.Repository` that stores content on the local file system.

  _IMPORTANT NOTE:_ This is intended as a reference implementation largely
  for testing purposes and may not necessarily handle all of the edge cases that
  the traditional `git` command-line interface will handle.

  That said, it does intentionally use the same `.git` folder format as command-line
  `git` so that results may be compared for similar operations.
  """
  use Xgit.Repository

  @doc ~S"""
  Start an on-disk git repository.

  Use the functions in `Xgit.Repository` to interact with this repository process.

  ## Options

  * `:work_dir` (required): Top-level working directory. A `.git` directory should
    exist at this path. Use `create/1` to create an empty on-disk repository if
    necessary.

  Any other options are passed through to `GenServer.start_link/3`.

  ## Return Value

  See `GenServer.start_link/3`.
  """
  @spec start_link(opts :: Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []), do: Repository.start_link(__MODULE__, opts, opts)

  @impl true
  def init(opts) when is_list(opts) do
    # TO DO: Be smarter about bare repos and non-standard git_dir locations.
    # https://github.com/elixir-git/xgit/issues/44

    with {:work_dir_arg, work_dir} when is_binary(work_dir) <-
           {:work_dir_arg, Keyword.get(opts, :work_dir)},
         {:work_dir, true} <- {:work_dir, File.dir?(work_dir)},
         git_dir <- Path.join(work_dir, ".git"),
         {:git_dir, true} <- {:git_dir, File.dir?(git_dir)} do
      {:ok, %{work_dir: work_dir, git_dir: git_dir}}
    else
      {:work_dir_arg, _} -> {:stop, :missing_arguments}
      {:work_dir, _} -> {:stop, :work_dir_doesnt_exist}
      {:git_dir, _} -> {:stop, :git_dir_doesnt_exist}
    end
  end

  @doc ~S"""
  Creates a new, empty git repository on the local file system.

  Analogous to [`git init`](https://git-scm.com/docs/git-init).

  _NOTE:_ We use the name `create` here so as to avoid a naming conflict with
  `c:GenServer.init/1`.

  ## Parameters

  `work_dir` (String) is the top-level working directory. A `.git` directory is
  created inside this directory.

  ## Return Value

  `:ok` if created successfully.

  `{:error, "reason"}` if not.
  """
  @spec create(work_dir :: String.t()) :: :ok | {:error, reason :: String.t()}
  defdelegate create(work_dir), to: Xgit.Repository.OnDisk.Create
end