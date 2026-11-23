// Ported from the old `contribution_editor.js.jsx`, which used the
// React.addons.update API (removed in React 15) and an implicit global RepoForm.
import React from 'react';
import update from 'immutability-helper';
import RepoForm from './RepoForm';

export default class ContributionEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      repo_link: this.props.repo_link,
      folders: [this.props.repo_link.folder],
    };
    this.onRepoChanged = this.onRepoChanged.bind(this);
    this.onChangeFolder = this.onChangeFolder.bind(this);
  }

  onRepoChanged(repo) {
    this.setState({
      repo_link: update(this.state.repo_link, { user_repo: { $set: repo } }),
    });
  }

  onChangeFolder(value) {
    this.setState({
      repo_link: update(this.state.repo_link, { folder: { $set: value } }),
    });
  }

  render() {
    const repo_link = this.state.repo_link;
    let repos = this.props.repos;

    if (this.props.user_repo && repos.indexOf(this.props.user_repo) === -1) {
      repos = update(repos, { $push: [this.props.user_repo] });
    }

    return (
      <div>
        <h2>First select a repo and optionally a folder within this repo</h2>
        <RepoForm
          repos={repos}
          repo_link={repo_link}
          url='/contribute/new'
          onChangeFolder={this.onChangeFolder}
          onRepoChanged={this.onRepoChanged}>
          <h2>Now please give it a name (this is mandatory) and a description (optional)</h2>
          <div className='control-group select optional repo_link_user_repo'>
            <label className='select optional control-label'>Contribution Title</label>
            <div className='controls'>
              <input name='contrb_title' placeholder='Obvious' id='contrb_title'></input>
            </div>
          </div>
          <div className='control-group select optional repo_link_user_repo'>
            <label className='select optional control-label'>Contribution Description</label>
            <div className='controls'>
              <textarea name='contrb_description' placeholder='Not Obvious'></textarea>
            </div>
          </div>
          <input className='btn btn-success btn-large' id='contribution_submit' type='submit' value='Create the contribution now' />
        </RepoForm>
      </div>
    );
  }
}
