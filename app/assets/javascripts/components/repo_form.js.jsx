class RepoForm extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      folders: [this.props.repo_link.folder],
      loading_folders: false
    };
  }

  onChangeFolder(event) {
    var value = event.target.value;
    this.props.onChangeFolder(value);
  }

  onRepoChanged(event) {
    var value = event.target.value;
    this.props.onRepoChanged(value);
    var folders = this.state.folders;
    this.setState({
      folders: [],
      loading_folders: true
    }, () => {
      $.getJSON('/contribute/repo_dirs/' + value).done(result => {
        this.setState({
          folders: result,
          loading_folders: false
        });
      }).fail(() => {
        this.setState({
          folders: folders,
          loading_folders: false
        });
      });
    });
  }

  render() {
    var repo_link = this.props.repo_link;
    var repos = this.props.repos;

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

    return (
      <form method='post' className='form-horizontal' action={this.props.url}>
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
        {this.props.children}
      </form>
    );
  }

}
