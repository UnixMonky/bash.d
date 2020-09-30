#!/bin/bash

cd ${HOME}
for F in bash_profile bashrc inputrc; do
  ln -fs bash.d/${F} .${F}
done