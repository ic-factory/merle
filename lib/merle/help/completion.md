Example:

  merle completion

Prints words for TAB auto-completion.

Examples:

  merle completion
  merle completion hello
  merle completion hello name

To enable, TAB auto-completion add the following to your profile:

  eval $(merle completion script)

Auto-completion example usage:

  merle [TAB]
  merle hello [TAB]
  merle hello name [TAB]
  merle hello name --[TAB]
