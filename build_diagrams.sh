#!/bin/bash
cd assets && find . -name "*.dot" -exec dot -Tpng -o{}.png {} \;
