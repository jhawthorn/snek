module ApplicationHelper
  def version_link(sha)
    show_url = "https://github.com/jhawthorn/snek/commits/#{sha}"
    current_sha = GitAdder.current_git_sha
    compare_url = "https://github.com/jhawthorn/snek/commits/#{sha}...#{current_sha}"
    if current_sha == sha
      link_to(sha, show_url) + " (current)"
    else
      link_to(sha, show_url) + " " + link_to("(compare)", compare_url)
    end
  end
end
