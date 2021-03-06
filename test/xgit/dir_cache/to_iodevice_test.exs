defmodule Xgit.DirCache.ToIoDeviceTest do
  use ExUnit.Case, async: true

  alias Xgit.DirCache
  alias Xgit.Test.OnDiskRepoTestCase
  alias Xgit.Util.TrailingHashDevice

  import FolderDiff

  describe "to_iodevice/1" do
    test "happy path: matches empty index generated by command-line git" do
      %{xgit_path: ref} = OnDiskRepoTestCase.repo!()
      %{xgit_path: xgit} = OnDiskRepoTestCase.repo!()

      # An initialized git repo doesn't have an index file at all.
      # Adding and removing a file generates an empty index file.

      {_output, 0} =
        System.cmd(
          "git",
          [
            "update-index",
            "--add",
            "--cacheinfo",
            "100644",
            "18832d35117ef2f013c4009f5b2128dfaeff354f",
            "hello.txt"
          ],
          cd: ref
        )

      {_output, 0} =
        System.cmd(
          "git",
          [
            "update-index",
            "--remove",
            "hello.txt"
          ],
          cd: ref
        )

      git_dir = Path.join(xgit, ".git")
      File.mkdir_p!(git_dir)

      index_path = Path.join(git_dir, "index")
      assert :ok = write_dir_cache_to_path(DirCache.empty(), index_path)

      assert_files_are_equal(Path.join([ref, ".git", "index"]), index_path)
    end

    test "happy path: can write an index file with two entries that matches command-line git" do
      %{xgit_path: ref} = OnDiskRepoTestCase.repo!()
      %{xgit_path: xgit} = OnDiskRepoTestCase.repo!()

      {_output, 0} =
        System.cmd(
          "git",
          [
            "update-index",
            "--add",
            "--cacheinfo",
            "100644",
            "18832d35117ef2f013c4009f5b2128dfaeff354f",
            "hello.txt"
          ],
          cd: ref
        )

      {_output, 0} =
        System.cmd(
          "git",
          [
            "update-index",
            "--add",
            "--cacheinfo",
            "100644",
            "d670460b4b4aece5915caf5c68d12f560a9fe3e4",
            "test_content.txt"
          ],
          cd: ref
        )

      dir_cache = %DirCache{
        entries: [
          %DirCache.Entry{
            assume_valid?: false,
            ctime: 0,
            ctime_ns: 0,
            dev: 0,
            extended?: false,
            gid: 0,
            ino: 0,
            intent_to_add?: false,
            mode: 0o100644,
            mtime: 0,
            mtime_ns: 0,
            name: 'hello.txt',
            object_id: "18832d35117ef2f013c4009f5b2128dfaeff354f",
            size: 0,
            skip_worktree?: false,
            stage: 0,
            uid: 0
          },
          %DirCache.Entry{
            assume_valid?: false,
            ctime: 0,
            ctime_ns: 0,
            dev: 0,
            extended?: false,
            gid: 0,
            ino: 0,
            intent_to_add?: false,
            mode: 0o100644,
            mtime: 0,
            mtime_ns: 0,
            name: 'test_content.txt',
            object_id: "d670460b4b4aece5915caf5c68d12f560a9fe3e4",
            size: 0,
            skip_worktree?: false,
            stage: 0,
            uid: 0
          }
        ],
        entry_count: 2,
        version: 2
      }

      git_dir = Path.join(xgit, ".git")
      File.mkdir_p!(git_dir)

      index_path = Path.join(git_dir, "index")
      assert :ok = write_dir_cache_to_path(dir_cache, index_path)

      assert_files_are_equal(Path.join([ref, ".git", "index"]), index_path)
    end

    @names [
      "a",
      "ab",
      "abc",
      "abcd",
      "abcde",
      "abcdef",
      "abcdefg",
      "abcdefgh",
      "ajaksldfjkadsfkasdfalsdjfklasdjf"
    ]

    test "happy path: can read from command-line git (varying name lengths)" do
      Enum.each(@names, fn name ->
        %{xgit_path: ref} = OnDiskRepoTestCase.repo!()
        %{xgit_path: xgit} = OnDiskRepoTestCase.repo!()

        {_output, 0} =
          System.cmd(
            "git",
            [
              "update-index",
              "--add",
              "--cacheinfo",
              "100644",
              "18832d35117ef2f013c4009f5b2128dfaeff354f",
              name
            ],
            cd: ref
          )

        dir_cache = %DirCache{
          entries: [
            %DirCache.Entry{
              assume_valid?: false,
              ctime: 0,
              ctime_ns: 0,
              dev: 0,
              extended?: false,
              gid: 0,
              ino: 0,
              intent_to_add?: false,
              mode: 0o100644,
              mtime: 0,
              mtime_ns: 0,
              name: :binary.bin_to_list(name),
              object_id: "18832d35117ef2f013c4009f5b2128dfaeff354f",
              size: 0,
              skip_worktree?: false,
              stage: 0,
              uid: 0
            }
          ],
          entry_count: 1,
          version: 2
        }

        git_dir = Path.join(xgit, ".git")
        File.mkdir_p!(git_dir)

        index_path = Path.join(git_dir, "index")
        assert :ok = write_dir_cache_to_path(dir_cache, index_path)

        assert_files_are_equal(Path.join([ref, ".git", "index"]), index_path)
      end)
    end

    test "happy path: matches --assume-unchanged flag behavior" do
      %{xgit_path: xgit} = OnDiskRepoTestCase.repo!()

      dir_cache = %DirCache{
        entries: [
          %DirCache.Entry{
            assume_valid?: false,
            ctime: 0,
            ctime_ns: 0,
            dev: 0,
            extended?: false,
            gid: 0,
            ino: 0,
            intent_to_add?: false,
            mode: 0o100644,
            mtime: 0,
            mtime_ns: 0,
            name: 'hello.txt',
            object_id: "18832d35117ef2f013c4009f5b2128dfaeff354f",
            size: 0,
            skip_worktree?: false,
            stage: 0,
            uid: 0
          },
          %DirCache.Entry{
            assume_valid?: true,
            ctime: 0,
            ctime_ns: 0,
            dev: 0,
            extended?: false,
            gid: 0,
            ino: 0,
            intent_to_add?: false,
            mode: 0o100644,
            mtime: 0,
            mtime_ns: 0,
            name: 'test_content.txt',
            object_id: "d670460b4b4aece5915caf5c68d12f560a9fe3e4",
            size: 0,
            skip_worktree?: false,
            stage: 0,
            uid: 0
          }
        ],
        entry_count: 2,
        version: 2
      }

      git_dir = Path.join(xgit, ".git")
      File.mkdir_p!(git_dir)

      index_path = Path.join(git_dir, "index")
      assert :ok = write_dir_cache_to_path(dir_cache, index_path)

      assert {:ok, ^dir_cache} =
               [xgit, ".git", "index"]
               |> Path.join()
               |> thd_open_file!()
               |> DirCache.from_iodevice()
    end

    test "error: unsupported version" do
      %{xgit_path: xgit} = OnDiskRepoTestCase.repo!()

      dir_cache = %DirCache{version: 3, entry_count: 0, entries: []}

      git_dir = Path.join(xgit, ".git")
      File.mkdir_p!(git_dir)

      index_path = Path.join(git_dir, "index")
      assert {:error, :unsupported_version} = write_dir_cache_to_path(dir_cache, index_path)
    end

    test "error: invalid" do
      %{xgit_path: xgit} = OnDiskRepoTestCase.repo!()

      dir_cache = %DirCache{version: 2, entry_count: 1, entries: []}

      git_dir = Path.join(xgit, ".git")
      File.mkdir_p!(git_dir)

      index_path = Path.join(git_dir, "index")
      assert {:error, :invalid_dir_cache} = write_dir_cache_to_path(dir_cache, index_path)
    end

    test "error: not SHA trailing hash device" do
      %{xgit_path: xgit} = OnDiskRepoTestCase.repo!()

      dir_cache = %DirCache{version: 2, entry_count: 0, entries: []}

      git_dir = Path.join(xgit, ".git")
      File.mkdir_p!(git_dir)

      index_path = Path.join(git_dir, "index")

      iodevice = File.open!(index_path, [:write])
      assert {:error, :not_sha_hash_device} = DirCache.to_iodevice(dir_cache, iodevice)
    end

    test "error: I/O error" do
      %{xgit_path: xgit} = OnDiskRepoTestCase.repo!()

      dir_cache = %DirCache{
        entries: [
          %DirCache.Entry{
            assume_valid?: true,
            ctime: 0,
            ctime_ns: 0,
            dev: 0,
            extended?: false,
            gid: 0,
            ino: 0,
            intent_to_add?: false,
            mode: 0o100644,
            mtime: 0,
            mtime_ns: 0,
            name: 'test_content.txt',
            object_id: "d670460b4b4aece5915caf5c68d12f560a9fe3e4",
            size: 0,
            skip_worktree?: false,
            stage: 0,
            uid: 0
          }
        ],
        entry_count: 1,
        version: 2
      }

      git_dir = Path.join(xgit, ".git")
      File.mkdir_p!(git_dir)

      index_path = Path.join(git_dir, "index")

      {:ok, iodevice} = TrailingHashDevice.open_file_for_write(index_path, max_file_size: 20)
      assert {:error, :eio} = DirCache.to_iodevice(dir_cache, iodevice)
    end
  end

  defp write_dir_cache_to_path(dir_cache, path) do
    with {:ok, iodevice} <- TrailingHashDevice.open_file_for_write(path),
         :ok <- DirCache.to_iodevice(dir_cache, iodevice) do
      File.close(iodevice)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp thd_open_file!(path) do
    {:ok, iodevice} = TrailingHashDevice.open_file(path)
    iodevice
  end
end
