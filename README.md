# Xgit

Pure Elixir native implementation of git [![Build Status](https://travis-ci.org/scouten/redo.svg?branch=master)](https://travis-ci.org/scouten/redo) [![Coverage Status](https://coveralls.io/repos/github/scouten/redo/badge.svg?branch=master)](https://coveralls.io/github/scouten/redo?branch=master)


## WORK IN PROGRESS

**This is very much a work in progress and not ready to be used in production.** What is implemented is well-tested and believed to be correct and stable, but much of the core git infrastructure is not yet implemented. There has been little attention, as yet, to measuring performance.

## Where Can I Help?

**TO DO:** Rewrite.

**There is also important work to be done in backfilling existing porting work.** Please see:

* [Issues tagged "good first issue"](https://github.com/scouten/redo/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
* [Issues tagged "help wanted"](https://github.com/scouten/redo/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) _more issues, but potentially more challenging_


## Why an All-Elixir Implementation?

With all of git already implemented in [libgit2](https://github.com/libgit2/libgit2), why do it again?

I considered that, and then I read [Andrea Leopardi](https://andrealeopardi.com/posts/using-c-from-elixir-with-nifs/):

> **NIFs are dangerous.** I bet you’ve heard about how Erlang (and Elixir) are reliable and fault-tolerant, how processes are isolated and a crash in a process only takes that process down, and other resiliency properties. You can kiss all that good stuff goodbye when you start to play with NIFs. A crash in a NIF (such as a dreaded segmentation fault) will **crash the entire Erlang VM.** No supervisors to the rescue, no fault-tolerance, no isolation. This means you need to be extremely careful when writing NIFs, and you should always make sure that you have a good reason to use them.

libgit2 is a big, complex library. And while it's been battle-tested, it's also a large C library, which means it takes on the risks cited above, will interfere with the Erlang VM scheduler, and make the build process far more complicated. I also hope to make it easy to make portions of the back-end (notably, storage) configurable; that will be far easier with an all-Elixir implementation.

## Credits

xgit is heavily influenced by [jgit](https://www.eclipse.org/jgit/), an all-Java implementation of git. Many thanks to the jgit team for their hard work. Small portions of xgit are based on an earlier port from Java to Elixir; those files retain the original credits and license from the jgit project.
