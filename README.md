# oh-my-zsh-custom

These are Andrew Janke's customizations to go with [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) ("OMZ").

I also have my other dotfiles on GitHub at https://github.com/apjanke/dotfiles, including the `.zshrc` and related config files I use to load and configure Oh My Zsh.

This OMZ custom dir includes:

* Stuff in pending Pull Requests for the main OMZ but I want active now
* My themes
* Alternate versions of things for testing

This is hosted on GitHub so other people working on OMZ can look at it when testing code, and so I can easily sync it to multiple machines of mine. This is not intended to provide significant functionality or reusable code of value. You probably do not want to use this as your own OMZ custom dir unless you're working an OMZ issue with me.

No support of any kind is provided for this code.

## Stuff currently included

Pending PRs:

* Timebox git status calls
 * https://github.com/robbyrussell/oh-my-zsh/pull/3914
* Clean up spectrum.zsh to avoid junking terminal
  * https://github.com/robbyrussell/oh-my-zsh/pull/3965
  * https://github.com/robbyrussell/oh-my-zsh/pull/3966
* omz_diagnostic_dump() function to help debugging
  * https://github.com/robbyrussell/oh-my-zsh/pull/3940
* A bit of stuff (but not the majority) from theme support unification
  * https://github.com/robbyrussell/oh-my-zsh/pull/3743

Other:

* BSD to GNU LSCOLORS conversion

TODO:

* Terminal.app support in main termsupport
 * https://github.com/robbyrussell/oh-my-zsh/pull/3582

## Usage

By convention, I clone this locally to `~/.oh-my-zsh-custom`, but any location will work. `$ZSH_CUSTOM` must be pointed at this in `~/.zshrc` before initializing OMZ.

## Author

Andrew Janke

andrew@apjanke.net

https://github.com/apjanke
https://apjanke.net

