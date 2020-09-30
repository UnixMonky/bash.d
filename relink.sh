#!/bin/bash

cd ${HOME}
for F in bash_profile bashrc inputrc; do
  ln -f bash.d/${F} .${F}
done