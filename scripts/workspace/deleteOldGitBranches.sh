for k in $(git branch | sed /\*/d); do 
  if [ -z "$(git log -1 --since='2 week ago' -s $k)" ]; then
    git branch -D $k
  fi
done
