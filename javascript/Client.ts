import AttributeTracker from './AttributeTracker';
import BindingManager from './BindingManager';
import Component from './Component';
import { documentLoaded, beforeDocumentUnload } from './documentLifecycle';
import Consumer from './Consumer';
import IClient from './interfaces/client_interface';

function getConfig(name: string) {
  const element = document.head.querySelector(`meta[name='action-cable-${name}']`);
  if (element) {
    return element.getAttribute('content');
  }

  return false;
}

export default class Client {
  _componentSelector: string

  keyAttribute: string

  stateAttribute: string

  motionAttribute: string

  logging: boolean

  _componentTracker: AttributeTracker

  _motionTracker: AttributeTracker

  root: HTMLDocument

  shutdownBeforeUnload: boolean

  consumer: Consumer;

  constructor(options: IClient) {
    this.consumer = new Consumer(getConfig('url') || '/cable');
    this.root = document;
    this.shutdownBeforeUnload = true;
    this.keyAttribute = 'data-motion-key';
    this.stateAttribute = 'data-motion-state';
    this.motionAttribute = 'data-motion';

    Object.assign(this, options);

    this._componentSelector = `[${this.keyAttribute}][${this.stateAttribute}]`;

    this.logging = true;

    this._componentTracker = new AttributeTracker(this.keyAttribute, (element: HTMLElement) => (
      element.hasAttribute(this.stateAttribute) // ensure matches selector
        ? new Component(this, element) : null
    ));

    this._motionTracker = new AttributeTracker(this.motionAttribute, (element: HTMLElement) => (
      new BindingManager(this, element)
    ));

    documentLoaded.then(() => { // avoid mutations while loading the document
      this._componentTracker.attachRoot(this.root);
      this._motionTracker.attachRoot(this.root);
    });

    if (this.shutdownBeforeUnload) {
      beforeDocumentUnload.then(() => this.shutdown());
    }
  }

  log(...args: Array<any>) {
    if (this.logging) {
      console.log('[Motion]', ...args);
    }
  }

  findComponent(element: HTMLElement) {
    return this._componentTracker.getManager(
      element.closest(this._componentSelector),
    );
  }

  shutdown() {
    this._componentTracker.shutdown();
    this._motionTracker.shutdown();
  }

  getExtraDataForEvent() {
    // noop
  }
}