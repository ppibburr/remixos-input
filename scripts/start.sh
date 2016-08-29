#!/bin/bash

killall -9 ruby
cd /home/ppibburr/remixos-input/bin
ruby /home/ppibburr/remixos-input/bin/remixos-input eth0 -o 0.0.0.0 touch

