require 'securerandom'

# Compare 2 branches for one repo or between repositories
# and return Gitlab::CompareResult object that responds to commits and diffs
class CompareService
  def execute(source_project, source_branch, target_project, target_branch)
    source_sha = source_project.commit(source_branch).sha

    # If compare with other project we need to fetch ref first
    unless target_project == source_project
      random_string = SecureRandom.hex

      target_project.repository.fetch_ref(
        source_project.repository.path_to_repo,
        "refs/heads/#{source_branch}",
        "refs/tmp/#{random_string}/head"
      )
    end

    Gitlab::CompareResult.new(
      Gitlab::Git::Compare.new(
        target_project.repository.raw_repository,
        target_branch,
        source_sha,
      )
    )
  end
end
