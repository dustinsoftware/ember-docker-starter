import Controller from '@ember/controller';

export default Controller.extend({
  actions: {
    saveBook(values) {
      let book = this.store.createRecord('book', values);

      book.save()
        .then(() => {
          this.transitionToRoute('book');
        });
    }
  }
});
