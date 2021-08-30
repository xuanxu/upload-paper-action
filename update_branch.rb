require "octokit"

def github_client
  @github_client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'], auto_paginate: true)
end

def get_main_ref(repo)
  github_client.refs(repo).select { |r| r[:ref] == "refs/heads/main" }.first.object.sha
end


issue_id = ENV["ISSUE_ID"]
pdf_path = ENV["PDF_PATH"]
papers_repo = ENV["PAPERS_REPO"]
branch_prefix = ENV["BRANCH_PREFIX"]

id = "%05d" % issue_id
branch = branch_prefix.empty? ? id.to_s : "#{branch_prefix}.#{id}"
ref = "heads/#{branch}"

begin
  files = github_client.contents(papers_repo, path: branch, ref: ref)
  files.each do |file|
    github_client.delete_contents(papers_repo, file.path, "Deleting #{file.name}", file.sha, branch: branch)
  end
  # Delete the old branch and create it again
  github_client.delete_ref(papers_repo, "heads/#{branch}")
  github_client.create_ref(papers_repo, "heads/#{branch}", get_main_ref(papers_repo))
rescue Octokit::NotFound # If the branch doesn't exist, or there aren't any commits in the branch then create it!
  begin
    github_client.create_ref(papers_repo, "heads/#{branch}", get_main_ref(papers_repo))
  rescue Octokit::UnprocessableEntity
    # If the branch already exists move on...
  end
end

uploaded_path = "#{branch}/10.21105.#{branch}.pdf"
gh_response = github_client.create_contents(papers_repo,
                                            uploaded_path,
                                            "Creating 10.21105.#{branch}.pdf",
                                            File.open("#{pdf_path.strip}").read,
                                            branch: branch)

`echo "::set-output name=paper_html_url::#{gh_response.content.html_url}"`
`echo "::set-output name=paper_download_url::#{gh_response.content.download_url}"`
