import { inject as service } from '@ember/service';
import Component from '@glimmer/component';
import { action, set } from '@ember/object';

export default class NewAuthorModal extends Component {
  @service()
  store;

  // passed in
  onsave = () => {};

  author = { first: 'doof', last: 'mcdoof'};

  @action
  save(ev) {
    ev.preventDefault();

    let author = this.store.createRecord('author', this.author);

    author.save().then(() => {
      set(this, 'showModal', false);

      this.onsave(author);
    });
  }
}
