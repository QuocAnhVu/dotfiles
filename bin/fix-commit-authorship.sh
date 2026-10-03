# Commit BEFORE the range you want to rewrite
BASE_COMMIT=main          # <-- change this

# Timezone you want to enforce (e.g. -0800 for US Pacific)
MY_TZ="-0800"                # <-- change this if needed

# Pull your identity from your current Git config
MY_NAME="$(git config user.name)"
MY_EMAIL="$(git config user.email)"

git filter-branch -f --env-filter '
if git merge-base --is-ancestor '"$BASE_COMMIT"' "$GIT_COMMIT"; then
    # Use the configured Git identity
    export GIT_AUTHOR_NAME="'"$MY_NAME"'"
    export GIT_AUTHOR_EMAIL="'"$MY_EMAIL"'"
    export GIT_COMMITTER_NAME="'"$MY_NAME"'"
    export GIT_COMMITTER_EMAIL="'"$MY_EMAIL"'"

    # Keep the same date/time, but replace the timezone
    export GIT_AUTHOR_DATE="${GIT_AUTHOR_DATE% *} '"$MY_TZ"'"
    export GIT_COMMITTER_DATE="${GIT_COMMITTER_DATE% *} '"$MY_TZ"'"
fi
' "$BASE_COMMIT"..HEAD

