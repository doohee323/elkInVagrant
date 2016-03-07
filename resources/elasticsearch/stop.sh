#!/bin/bash

ES=$PROJ_DIR/node1
kill `cat < $ES/bin/es1.pid`

ES=$PROJ_DIR/node2
kill `cat < $ES/bin/es2.pid`

ES=$PROJ_DIR/node3
kill `cat < $ES/bin/es3.pid`