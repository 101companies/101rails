class ContributionEditor extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      repo_link: this.props.repo_link,
      folders: [this.props.repo_link.folder]
    };
  }

  onRepoChanged(repo) {
    var new_repo_link = React.addons.update(this.state.repo_link, {
      user_repo: {
        $set: repo
      }
    });
    this.setState({
      repo_link: new_repo_link
    });
  }

  onChangeFolder(value) {
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

    return (<div>
      <h2>First select a repo and optionally a folder within this repo</h2>
      <RepoForm
        repos={repos}
        repo_link={repo_link}
        onChangeFolder={this.onChangeFolder.bind(this)}
        onRepoChanged={this.onRepoChanged.bind(this)}>
        <h2>Now please give it a name (this is mandatory)</h2>
        <div className="control-group select optional repo_link_user_repo">
          <label className="select optional control-label">Contribution Title</label>
          <div className="controls">
            <input name="contrb_title" placeholder="Obvious" id="contrb_title"></input>
          </div>
        </div>
        <div className="control-group select optional repo_link_user_repo">
          <label className="select optional control-label">Contribution Description</label>
          <div className="controls">
            <textarea name="contrb_description" placeholder="Not Obvious"></textarea>
          </div>
        </div>
        <input className="btn btn-success btn-large" id="contribution_submit" type="submit" value="Create the contribution now" />
      </RepoForm>
    </div>);
  }
}
