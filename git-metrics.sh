#!/bin/sh

if [[ $# -eq 0 ]]; then
    read -p "review_year=" review_year
else
    review_year=$1
fi

start_date="${review_year}-01-01 00:00"
end_date="${review_year}-12-31 23:59"

# git show <commit> --name-status
# todo: figure out how to get the commits that are closest to input dates
first_commit=(git rev-list -n 1 --after="${start_date}" master) # get first commit
last_commit=(git rev-list -n 1 --reverse --before="${end_date}" master) # get last commit

all_files=(git diff ${first_commit} ${last_commit} --name-only) # get all files
new_files=(git diff ${first_commit} ${last_commit} --name-status \| grep "A") # get added files - new code
maintained_files=(git diff ${first_commit} ${last_commit} --name-status \| grep "M") # get modified files - maintenance

count_all_files=(echo "${all_files}" \| wc -l)
count_new_files=(echo "${new_files}" \| wc -l)
count_maintained_files=(echo "${maintained_files}" \| wc -l)

echo "=========="
echo "Year review: ${review_year}"
echo "All files: ${count_all_files}"
if ((${count_all_files} > 0)); then
    echo "New files: ${count_new_files}"
    echo "Maintained files: ${count_maintained_files}"
    echo "Maintenance percent: " $((${count_maintained_files} / ${count_all_files} * 100))"%"
fi
echo "=========="