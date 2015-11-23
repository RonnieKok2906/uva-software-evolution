module CloneTypes

alias CodeFragment = tuple[loc compilationUnit, loc fragment];

alias Clone = rel[CodeFragment, CodeFragment];
alias CloneClass = list[CodeFragment];