import git
repo = git.Repo(__file__,search_parent_directories=True)
sha = repo.head.object.hexsha

print (__file__, sha)
