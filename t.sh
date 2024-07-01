adjust_date() {
    case "$1" in
        "2024-08-06 14:00:24 -0700") echo "2023-08-06 14:00:24 -0700" ;;
        "2024-08-06 13:59:19 -0700") echo "2023-08-06 13:59:19 -0700" ;;
        "2024-08-06 13:57:54 -0700") echo "2023-08-06 13:57:54 -0700" ;;
        "2024-08-06 01:01:01 -0700") echo "2023-08-06 01:01:01 -0700" ;;
        *) echo "$1" ;;
    esac
}

reflog_entries=$(git reflog --date=iso | grep -E "202[5-9]")

echo "$reflog_entries" | while IFS= read -r entry; do
    commit_hash=$(echo "$entry" | awk '{print $1}')
    original_date=$(echo "$entry" | awk '{print $3" "$4" "$5" "$6}')
    adjusted_date=$(adjust_date "$original_date")

    git checkout $commit_hash
    GIT_COMMITTER_DATE="$adjusted_date" git commit --amend --no-edit --date="$adjusted_date"
done

git checkout master
