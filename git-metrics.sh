#!/bin/sh

if [[ $# -eq 0 ]]; then
    read -p "review_year=" review_year
else
    review_year=$1
fi

default_branch="master"
start_date="${review_year}-01-01 00:00"
end_date="${review_year}-12-31 23:59"

# git show <commit> --name-status
# todo: figure out how to get the commits that are closest to input dates

# git log -q --reverse --after="2022-01-01" --before="2022-12-31" master | grep commit | head -n 1 | cut -d' ' -f2-
beginning_commits=$(git log -q --reverse --after="${start_date}" --before="${end_date}" ${default_branch} | grep commit)
# git log -q --after="2022-01-01" --before="2022-12-31" master | grep commit | head -n 1 | cut -d' ' -f2-
ending_commits=$(git log -q --after="${start_date}" --before="${end_date}" ${default_branch} | grep commit)

first_commit=$(echo "${beginning_commits}" | head -n 1 | cut -d' ' -f2-) # get first commit
# first_commit=$(git log --q --reverse --after="${start_date}" --before="${end_date}" ${default_branch} | grep commit | head -n 1 | cut -d' ' -f2-) # get first commit
last_commit=$(echo "${ending_commits}" | head -n 1 | cut -d' ' -f2-) # get last commit
# last_commit=$(git log --after="${start_date}" --before="${end_date}" ${default_branch} | grep commit | head -n 1 | cut -d' ' -f2-) # get last commit

echo "First commit of year: ${first_commit}"
#git show ${first_commit} --name-only
echo "Last commit of year: ${last_commit}"
#git show ${last_commit} --name-only

all_files=$(git diff ${first_commit} ${last_commit} --name-only) # get all files
new_files=$(git diff ${first_commit} ${last_commit} --name-status | grep "A") # get added files - new code
maintained_files=$(git diff ${first_commit} ${last_commit} --name-status | grep "M") # get modified files - maintenance

count_all_files=$(echo "${all_files}" | wc -l)
count_new_files=$(echo "${new_files}" | wc -l)
count_maintained_files=$(echo "${maintained_files}" | wc -l)

# help: [ https://stackoverflow.com/questions/9468970/how-to-get-a-count-of-all-the-files-in-a-git-repository ]
count_total_files=$(git ls-files | wc -l)
# help: [ https://stackoverflow.com/questions/4822471/count-number-of-lines-in-a-git-repository ]
count_total_lines=$(git grep ^ | wc -l)

# help: [ https://stackoverflow.com/questions/2528111/how-can-i-calculate-the-number-of-lines-changed-between-two-commits-in-git ]
git_status=$(git diff --stat ${first_commit} ${last_commit} | tail -n 1)

echo "=========="
echo "Project size in files: ${count_total_files}"
echo "Project size in lines: ${count_total_lines}"
echo "----------"
echo "Year review: ${review_year}"
if ((${count_all_files} > 0)); then
    echo "All files between dates: ${count_all_files}"
    echo "New files: ${count_new_files}"
    echo "Maintained files: ${count_maintained_files}"
    echo "Maintenance percent: "$(( 100 * ${count_maintained_files} / ${count_all_files} ))" %"
    echo "Git status: ${git_status}"
fi
echo "=========="