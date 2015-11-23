module model::CloneModel

import model::CodeLineModel;

alias CodeFragment = list[CodeLine];
alias CloneClass = list[CodeFragment];

alias CloneModel = list[CloneClass];