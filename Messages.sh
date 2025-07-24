#!/usr/bin/env bash
$XGETTEXT `find . -name \*.qml -o -name \*.js` -o $podir/gamemodechecker.pot
