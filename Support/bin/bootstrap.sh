#!/usr/bin/env bash

source "$TM_SUPPORT_PATH/lib/bash_init.sh"

export TM_RUBY=${TM_RUBY:-ruby}
export TM_SVN=${TM_SVN:-svn}

require_cmd "$TM_SVN" "If you have installed svn, then you need to either <a href=\"help:anchor='search_path'%20bookID='TextMate%20Help'\">update your <tt>PATH</tt></a> or set the <tt>TM_SVN</tt> shell variable (e.g. in Preferences / Advanced)"

script=$1
shift

bin=$(dirname "$0")

$TM_RUBY "$bin/$script.rb" $@ >& /dev/null &