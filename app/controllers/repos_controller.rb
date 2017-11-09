require 'fileutils'
# require './lib/repos_support'
# require './lib/git_api_support'

class ReposController < ApplicationController
  include ReposSupport
  include GitApiSupport

  def getInfoAsync
    resp = {"repo":0,"module":[]}
    name = params[:name]
    repo = Repo.find_by(name: name)
    repo.part.all.each do |modul|
      entry = {"name":modul.name,"state":modul.state}
      resp[:module].push(entry)
    end
    resp[:repo] = repo.state
    render json: resp
  end

  def sendDownload
    repo = Repo.find_by(name: params[:name])
    if repo != nil
      if repo.state == 2
        resultPath = SystemSetting.find_by(name: "Result_Path").value
        path = File.join(resultPath,repo.raw_repo.name,repo.name+'.zip')
        send_file(path)
      else
        flash[:error] = "There are actually some analysis running on this repositorie, please wait until they are finished"
        redirect_to(repo)
      end
    end
  end






    def index
      stop = SystemSetting.find_by(name: 'Stop')
      if stop == nil || stop.value.to_i == -1
        flash[:error] = 'The service is actually unavailable'
        redirect_to '/wiki'
        return
      end
      if params[:link] != nil
        @link = params[:link]
      end
      if params[:branch] != nil
        @branch = params[:branch]
      end
      if params[:rev] != nil
        @rev = params[:rev]
      end
      @allModules = getModulesFromJson
      @allRepos = Repo.all
    end



    def create

      @allModules = getModulesFromJson

      if !checkGithubRequestAvailable
        flash[:error] = "Actually our service is to busy, try it again later"
        render 'index'
        return
      end

      @allModules = getModulesFromJson
      modules = []
      modulselected = 0

      repoData = params.require('repoData').permit(:link,:revision,:branch)


      if !checkIfRepoExistsOnSource(repoData['link'])
        flash[:error] ="The Repository could not be found with the provided link"
        @link = repoData['link']
        @rev = repoData['revision']
        @branch = repoData['branch']
        render 'index'
        return
      end

      if repoData['branch'] != '' && repoData['revision'] == '' && checkIfBranchExists(repoData['link'],repoData['branch'])
        flash[:error] = "Your defined branch could not be found"
        render 'index', params: {link: repoData['link'], rev: repoData['revision'], branch: repoData['branch']}
        return
      end
      if repoData['revision'] != '' && checkIfCommitByShaExists(repoData['link'],repoData['revision'])
        flash[:error] = "Your defined revision could not be found, please check your input"
        render 'index', params: {link: repoData['link'], rev: repoData['revision'], branch: repoData['branch']}
        return
      end
      revision = getRevisionOfRepo(repoData['link'],repoData['branch'],repoData['revision'])

      @allModules.each do |mod|
        if (params.require(:repoData).permit(mod))[mod].to_i == 1
          modules.push(mod.to_s)#scheinbar fällt bei to_s automatisch ':' weg
          modulselected = 1
        end
      end
      modules = getModuleExecutionOrder(modules)

      if modulselected == 0
        flash[:error] = "Please select a Module, before submitting a analysis"
        render 'index', params: {link: repoData['link'], rev: repoData['revision'], branch: repoData['branch']}
        return
      end


      maxSize = SystemSetting.find_by(name: 'Maximum_Size_Raw_Repo').value
      size = getSizeOfRepo(repoData['link'])
      if size < 0 || size > maxSize.to_i
        flash[:error] = "The size of the Repo is to high"
        render 'index', params: {link: repoData['link'], rev: repoData['revision'], branch: repoData['branch']}
        return
      end

      repoName = linkToName(repoData['link'],revision)
      raw_repo_name = linkToName(repoData['link'],'')
      repo = Repo.find_by(name: repoName)
      if repo == nil
        link = repoData['link']
        raw_repo = RawRepo.find_by(name: raw_repo_name)
        if raw_repo == nil
          raw_repo = RawRepo.create(name: raw_repo_name, state: -1, size: size)
          raw_repo.save
        end
        repo = raw_repo.repo.new(name: repoName, link: link, rev: revision, state: 0,size: 0)
        repo.save
      end
      if createModulePage(repo,modules)#false, if no new modules exist
        AnalyseJob.perform_async(repoData['link'], revision, repoName, size, modules)
      end
      redirect_to repo
    end

    def show
      @repo = Repo.find_by(name: params['name'])
    end

  end
