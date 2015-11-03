
class RepoEditor extends React.Component {

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

    var url_to_send = '/contribute/update/' + page.url;

    return (<div>
      <RepoForm
        url={url_to_send}
        csrf_token={this.props.csrf_token}
        repos={repos}
        repo_link={repo_link}
        onChangeFolder={this.onChangeFolder.bind(this)}
        onRepoChanged={this.onRepoChanged.bind(this)}>
        <input className="btn btn-success" id="update_page_button" name="commit" type="submit" value="Save repo link" />
      </RepoForm>
    </div>);
  }

}
