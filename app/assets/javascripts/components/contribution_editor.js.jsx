class ContributionEditor extends React.Component {

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
    var repo_link = this.state.repo_link;
    var repos = this.props.repos;

    if(this.props.user_repo && repos.indexOf(this.props.user_repo) == -1) {
      repos = React.addons.update(repos, {
        $push: [this.props.user_repo]
      });
    }

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
      <form method='post' id='create_contribution' accept-charset='UTF-8' action='/contribute/new'>
        <input name='authenticity_token' type='hidden' value={this.props.csrf_token} />
        <p>
         <label>
             Give it a name
         </label>
        </p>
        <p>
         <input id="contribution_title" placeholder="Obvious" name="contrb_title"></input>
        </p>
        <p>
          <label className="select optional control-label" htmlFor="repo_link_user_repo">
            Choose a GitHub repo
          </label>
        </p>
        <p>
         <select
                    name="contrb_repo_url"
                    id="contrb_repo_url"
                    onChange={this.onRepoChanged.bind(this)}>
              {options}
         </select>
        </p>
        <p>
          <label>
            Select a folder within the repo
          </label>
        </p>
        <p>
          <select onChange={this.onChangeFolder.bind(this)} id="contrb_folder" name="contrb_folder">
              {folders}
          </select>
        </p>
        <p>
	 <label>
             Give it a description
           </label>
	</p>
        <p>
 	 <textarea name="contrb_description" placeholder="Not obvious"></textarea>
	</p>
        <p>
         <button className="btn btn-large btn-success" id="contribution_submit" type="submit">Create Contribution</button>        
        </p>
      </form>
    </div>);
  }

}