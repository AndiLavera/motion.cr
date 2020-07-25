import AttributeTracker from './AttributeTracker';
import BindingManager from './BindingManager';
import Component from './Component';
import { documentLoaded, beforeDocumentUnload } from './documentLifecycle';
import Consumer from './Consumer';

function getConfig(name) {
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

  root: Document

  shutdownBeforeUnload: boolean

  defaultOptions: IClient

  consumer: Consumer

  constructor(options: IClient) {
    Object.assign(this, Client.defaultOptions, options);

    this._componentSelector = `[${this.keyAttribute}][${this.stateAttribute}]`;

    this.logging = true;

    this._componentTracker = new AttributeTracker(this.keyAttribute, (element) => (
      element.hasAttribute(this.stateAttribute) // ensure matches selector
        ? new Component(this, element) : null
    ));

    this._motionTracker = new AttributeTracker(this.motionAttribute, (element) => (
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

  log(...args) {
    if (this.logging) {
      console.log('[Motion]', ...args);
    }
  }

  findComponent(element) {
    return this._componentTracker.getManager(
      element.closest(this._componentSelector),
    );
  }

  shutdown() {
    this._componentTracker.shutdown();
    this._motionTracker.shutdown();
  }
}

interface IClient {
  getExtraDataForEvent: Function
  logging: boolean
  root: Document
  shutdownBeforeUnload: boolean
  keyAttribute: string
  stateAttribute: string
  motionAttribute: string
}

Client.defaultOptions = {
  get consumer() {
    return new Consumer(getConfig('url') || '/cable');
  },

  getExtraDataForEvent() {
    // noop
  },

  logging: false,

  root: document,
  shutdownBeforeUnload: true,

  keyAttribute: 'data-motion-key',
  stateAttribute: 'data-motion-state',
  motionAttribute: 'data-motion',
};
