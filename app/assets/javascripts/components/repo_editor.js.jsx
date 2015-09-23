// <%= simple_form_for(repo_link, :html => {:class => 'form-horizontal' }, :url => url_to_send) do |f| %>
//   <%= f.input :user_repo, :label => 'GitHub repo', :collection => repos_to_show, :include_blank => true %>
//   <%= f.input :folder, :collection => [repo_link.folder], :include_blank => true %>
//   <% if @page.title.nil? %>
//     <%= f.input :page_title %>
//   <% end %>
//   <% if is_contribution_process %>
//     <%= f.submit 'Submit contribution', :class => 'btn btn-success', :id => 'update_page_button' %>
//   <% else %>
//     <%= f.submit 'Save repo link', :class => 'btn btn-success', :id => 'update_page_button' %>
//   <% end %>
// <% end %>
//
// <% if (!repo_link.repo.nil?) && (!(repo_link.repo.strip == '')) %>
//   <div>Repo Link</div>
// <% end %>


class RepoEditor extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      repo_link: this.props.repo_link,
      folders: [this.props.repo_link.folder]
    };
  }

  onRepoChanged(event) {
    var value = event.target.value;
    var new_repo_link = React.addons.update(this.state.repo_link, {
      user_repo: {
        $set: value
      }
    });
    this.setState({
      repo_link: new_repo_link,
      folders: [],
      loading_folders: true
    }, () => {
      $.getJSON('/contribute/repo_dirs/' + value, (result) => {
        this.setState({
          folders: result,
          loading_folders: false
        })
      });
    });
  }

  onChangeFolder(event) {
    var value = event.target.value;

    var new_repo_link = React.addons.update(this.state.repo_link, {
      folder: {
        $set: value
      }
    });
    this.setState({
      repo_link: new_repo_link
    });
  }

  render() {
    var page = this.props.page;
    var repo_link = this.state.repo_link;
    var repos = this.props.repos;

    if(this.props.user_repo && repos.indexOf(this.props.user_repo) == -1) {
      repos = React.addons.update(repos, {
        $push: [this.props.user_repo]
      });
    }

    var url_to_send = '/contribute/update/' + page.url;

    var options = repos.map((repo) => {
      return <option value={repo} key={repo}>{repo}</option>;
    });
    options = React.addons.update([<option key={'0'} value=''></option>], {
      $push: options
    });

    var folders;
    if(this.state.loading_folders) {
      folders = [<option key={'0'} value=''>Folders are being loaded ...</option>]
    }
    else {
      folders = this.state.folders.map((folder) => {
        return <option key={folder} value={folder}>{folder}</option>;
      });
      folders = React.addons.update([<option key={'0'} value=''></option>], {
        $push: folders
      });
    }

    return (<div>
      <form method='post' className='form-horizontal' action={url_to_send}>
        <input name='authenticity_token' type='hidden' value={this.props.csrf_token} />
        <div className="control-group select optional repo_link_user_repo">
          <label className="select optional control-label" htmlFor="repo_link_user_repo">
            GitHub repo
          </label>
          <div className="controls">
            <select className="select optional"
                    name="repo_link[user_repo]"
                    id="repo_link_user_repo"
                    onChange={this.onRepoChanged.bind(this)}
                    value={repo_link.user_repo}>
              {options}
            </select>
          </div>
        </div>
        <div className="control-group select optional repo_link_folder">
          <label className="select optional control-label" htmlFor="repo_link_folder">
            Folder
          </label>

          <div className="controls">
            <select className="select optional" onChange={this.onChangeFolder.bind(this)} id="repo_link_folder" name="repo_link[folder]" value={repo_link.folder}>
              {folders}
            </select>
          </div>
        </div>
        <input className="btn btn-success" id="update_page_button" name="commit" type="submit" value="Save repo link" />
      </form>
    </div>);
  }

}
