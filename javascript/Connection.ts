import Socket from './Socket';
import Channel from './Channel';
import Consumer from './Consumer';
import Subscriptions from './Subscriptions';
import Subscription from './Subscription';

class Connection {
  socket: Socket;

  consumer: Consumer;

  subscriptions: Subscriptions;

  disconnected: boolean;

  channel: Channel | undefined;

  reopenDelay: number;

  connectionPromise: Promise<any>;

  channels: Array<Channel>

  constructor(consumer: Consumer) {
    this.socket = new Socket('/cable');
    this.connectionPromise = this.open.call(this);
    this.consumer = consumer;
    this.subscriptions = this.consumer.subscriptions;
    this.disconnected = true;
    this.channel = undefined;
    this.channels = [];
    this.reopenDelay = 500;
    this.handleWindowOffload()
  }

  send(data): void {
    this.connectionPromise.then(() => {
      const topic = data.identifier.channel
      this.channels.forEach(channel => {
        if (channel.topic === topic) { channel.push('message_new', data) }
      })
    });
  }

  joinChannel(data: Subscription): void {
    this.connectionPromise.then(() => {
      debugger
      data.connected();
      this.channel = this.socket.channel(data.channel);
      this.channels.push(this.channel)

      this.channel.join({ identifier: data.identifier });

      this.channel.on('message_new', (payload) => {
        data.received(payload.html);
      });

      this.channel.on('leave', (payload) => {
        console.log(payload);
      });
    });
  }

  open(): Promise<void> {
    return this.socket.connect();
  }

  close({ allowReconnect } = { allowReconnect: true }): void {
    return this.socket.disconnect();
  }

  // TODO
  /* eslint-disable class-methods-use-this */
  isActive(): boolean {
    return true;
  }
  /* eslint-enable class-methods-use-this */

  // For some reason the documentLifecycle promise wasn't ever hitting this
  // Check client & client#shutdown for more info
  handleWindowOffload(): void {
    window.addEventListener('beforeunload', this.shutdown.bind(this))
  }

  shutdown(): void {
    this.channels.forEach(channel => {
      channel.push('unsubscribe', { command: 'unsubscribe' })
    })
  }
}

export default Connection;
