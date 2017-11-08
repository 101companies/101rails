class PartsController < ApplicationController
  require 'json'

  def show
    @repo = Repo.find_by(name: params['repo_name'])
    @module = @repo.part.find_by(name: params['name'])

    if @module.state == 0
      redirect_to @repo
    else
      @dependsOn = []
      json = JSON.parse(@module.dependsOn)
      json.each do |mod|
        modul = @repo.part.find_by(name: mod)
        @dependsOn.append(modul)
      end
      @examples = JSON.parse(@module.result)
    end

  end
end
