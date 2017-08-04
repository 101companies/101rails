require 'json'
require 'net/http'

module GitApiSupport


  def authKey()
    authKey = "?access_token="+ENV["GITKEY"]
  end


  def makeRequest(url)
    uri = URI(url+authKey())
    res = Net::HTTP.get_response(uri)
    res.body
  end


  def checkGithubRequestAvailable()
    data = JSON.parse(makeRequest('https://api.github.com/rate_limit'))
    if data['resources']['core']['remaining'] > 20 #change later to 150 when github authentication with 5000 req allowed
      true
    else
      false
    end
  end


  def getSizeOfRepo(link)
    parts = link.chomp('.git').split('/')
    url = 'https://api.github.com/repos/' + parts[-2] + '/' + parts[-1]
    data = JSON.parse(makeRequest(url))
    data['size'] #in kb
  end

  def checkIfBranchExists(link,branch)
    parts = link.chomp('.git').split('/')
    url = 'https://api.github.com/repos/' + parts[-2] + '/' + parts[-1] +'/branches/'+branch
    data = JSON.parse(makeRequest(url))
    if data['message'] == nil
      false
    else
      true
    end
  end

  def checkIfCommitByShaExists(link,rev)
    parts = link.chomp('.git').split('/')
    url = 'https://api.github.com/repos/' + parts[-2] + '/' + parts[-1] +'/commits/'+rev
    data = JSON.parse(makeRequest(url))
    if data['message'] == nil
      false
    else
      true
    end
  end

  def getRevisionOfRepo(link,branch,revision)
    if revision != ''
      rev = revision
    else
      if branch == ''
        branch = getDefaultBranchOfRepo(link)
        rev = getTopRevisionOfBranch(link,branch)
      else
        rev = getTopRevisionOfBranch(link,branch)
      end
    end
    rev
  end

  def getDefaultBranchOfRepo(link)
    parts = link.chomp('.git').split('/')
    url = 'https://api.github.com/repos/' + parts[-2] + '/' + parts[-1]
    data = JSON.parse(makeRequest(url))
    data['default_branch']
  end

  def getTopRevisionOfBranch(link,branch)
    parts = link.chomp('.git').split('/')
    url = 'https://api.github.com/repos/' + parts[-2] + '/' + parts[-1] +'/branches/'+branch
    data = JSON.parse(makeRequest(url))
    if data['message'] == nil
      data['commit']['sha']
    else
      ''
    end
  end

  def checkIfRepoExistsOnSource(link)
    parts = link.chomp('.git').split('/')
    if parts[-2] == nil || parts[-1] == nil
      false
    else
      url = 'https://api.github.com/repos/' + parts[-2] + '/' + parts[-1]
      data = JSON.parse(makeRequest(url))
      if data['message'] == nil
        true
      else
        false
      end
    end
  end

end
