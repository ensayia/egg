# egg - minimal node organized note taking program

egg requires the LOVE framework, available on all operating systems - [https://love2d.org](https://love2d.org)

## why

I desperately wanted a program for simple organized note taking. Most options out there are either overly complicated for my needs or have silly depenency requirements.

egg is guided by the idea of simplicity and minimalism. If you're looking for something feature complete there are plenty of good options out there (check out [cherrytree](https://www.giuspen.com/cherrytree/) for a solid full-featured option).

## keys
egg does not have mouse support
- up/down/left/right : navigate within nodes/text
- enter : edit node content, create a newline
- esc : exit text edit mode, double tap to quit program
- ctrl + n : create new primary node
- n : create new subnode
- ctrl + e : edit node name
- d : delete node
- ctrl + s : save
- space : collapse node children

- f1: help menu
- f2: options menu

## features
- egg notes are stored in a lua table hierarchy, serialized and saved into a lua file
- egg saves on exit, and also creates an incremental backup with each save
- egg has full utf-8 support and utilizes the Deja Vu Sans Mono font
