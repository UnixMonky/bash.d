###
# git status
###

num_staged=0
num_changed=0
num_conflicts=0
num_untracked=0
while IFS='' read -r line || [[ -n "$line" ]]; do
  status=${line:0:2}
  while [[ -n $status ]]; do
    case "$status" in
      #two fixed character matches, loop finished
      \#\#) branch_line="${line/\.\.\./^}"; break ;;
      \?\?) ((num_untracked++)); break ;;
      U?) ((num_conflicts++)); break;;
      ?U) ((num_conflicts++)); break;;
      DD) ((num_conflicts++)); break;;
      AA) ((num_conflicts++)); break;;
      #two character matches, first loop
      ?M) ((num_changed++)) ;;
      ?D) ((num_changed++)) ;;
      ?\ ) ;;
      #single character matches, second loop
      U) ((num_conflicts++)) ;;
      \ ) ;;
      *) ((num_staged++)) ;;
    esac
    status=${status:0:(${#status}-1)}
  done
done <<< "$(LC_ALL=C git status --untracked-files=${__GIT_PROMPT_SHOW_UNTRACKED_FILES:-all} --porcelain --branch)"
