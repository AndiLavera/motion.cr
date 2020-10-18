import Connection from './Connection';
import Subscriptions from './Subscriptions';
import Subscription from './Subscription';

export function createWebSocketURL(inputUrl: string | Function) {
  const url = typeof inputUrl === 'function' ? inputUrl() : inputUrl;

  if (url && !/^wss?:/i.test(url)) {
    const a = document.createElement('a');
    a.href = url;
    // Fix populating Location properties in IE. Otherwise, protocol will be blank.
    a.href = a.href; // eslint-disable-line no-self-assign
    a.protocol = a.protocol.replace('http', 'ws');
    return a.href;
  }
  return url;
}

export default class Consumer {
  _url: string;

  subscriptions: Subscriptions;

  connection: Connection;

  constructor(url: string) {
    this._url = url;
    this.subscriptions = new Subscriptions(this);
    this.connection = new Connection(this);
  }

  get url() {
    return createWebSocketURL(this._url);
  }

  send(data): void {
    return this.connection.send(data);
  }

  joinChannel(data: Subscription): void {
    return this.connection.joinChannel(data);
  }

  connect(): void {
    return this.connection.open();
  }

  disconnect(): void {
    return this.connection.close({ allowReconnect: false });
  }

  ensureActiveConnection(): Promise<void> | boolean {
    if (!this.connection.isActive()) {
      return this.connection.open();
    }

    return false;
  }
}
