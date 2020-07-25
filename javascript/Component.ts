import dispatchEvent from './dispatchEvent';
import serializeEvent from './serializeEvent';
import reconcile from './reconcile';
import Client from './Client';

import { version } from '../package.json';

export default class Component {
  client: Client

  element: HTMLElement

  _subscription: Subscription

  constructor(client: Client, element: HTMLElement) {
    this.client = client;
    this.element = element;

    this._beforeConnect();

    this._subscription = this.client.consumer.subscriptions.create(
      {
        channel: `motion:${Math.floor(Math.random() * 10000)}`,
        version: '0.1.0', // import version
        state: this.element.getAttribute(this.client.stateAttribute),
      },
      {
        connected: () => this._connect(),
        rejected: () => this._connectFailed(),
        disconnected: () => this._disconnect(),
        received: (newState) => this._render(newState),
      },
    );
  }

  processMotion(name: string, event = null) {
    if (!this._subscription) {
      this.client.log('Dropped motion', name, 'on', this.element);
      return;
    }

    this.client.log('Processing motion', name, 'on', this.element);

    const extraDataForEvent = event && this.client.getExtraDataForEvent(event);

    this._subscription.perform(
      {
        name,
        event: event && serializeEvent(event, extraDataForEvent),
      },
    );
  }

  shutdown() {
    this._subscription.unsubscribe();
    delete this._subscription;

    this._disconnect();
  }

  _beforeConnect() {
    this.client.log('Connecting component', this.element);

    dispatchEvent(this.element, 'motion:before-connect');
  }

  _connect() {
    // debugger
    this.client.log('Component connected', this.element);

    dispatchEvent(this.element, 'motion:connect');
  }

  _connectFailed() {
    this.client.log('Failed to connect component', this.element);

    dispatchEvent(this.element, 'motion:connect-failed');
  }

  _disconnect() {
    this.client.log('Component disconnected', this.element);

    dispatchEvent(this.element, 'motion:disconnect');
  }

  _render(newState) {
    // debugger
    dispatchEvent(this.element, 'motion:before-render');

    reconcile(
      this.element,
      newState, // newState,
      this.client.keyAttribute,
    );

    this.client.log('Component rendered', this.element);

    dispatchEvent(this.element, 'motion:render');
  }
}
