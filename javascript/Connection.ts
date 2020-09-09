import Amber from './Amber';
import Consumer from './Consumer';
import Subscriptions from './Subscriptions';
import Subscription from './Subscription';

class Connection {
  socket: Amber.Socket;

  consumer: Consumer;

  subscriptions: Subscriptions;

  disconnected: boolean;

  channel: Amber.Channel | undefined;

  reopenDelay: number;

  connectionPromise: Promise<any>;

  channels: Array<Amber.Channel>

  constructor(consumer: Consumer) {
    this.socket = new Amber.Socket('/cable');
    this.connectionPromise = this.open.call(this);
    this.consumer = consumer;
    this.subscriptions = this.consumer.subscriptions;
    this.disconnected = true;
    this.channel = undefined;
    this.channels = [];
    this.reopenDelay = 500;
  }

  send(data) {
    this.connectionPromise.then(() => {
      const topic = data.identifier.channel
      this.channels.forEach(channel => {
        if (channel.topic === topic) { channel.push('message_new', data) }
      })
    });
  }

  joinChannel(data: Subscription) {
    this.connectionPromise.then(() => {
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

  open() {
    return this.socket.connect();
  }

  close({ allowReconnect } = { allowReconnect: true }) {
    return this.socket.disconnect();
  }

  /* eslint-disable class-methods-use-this */
  isActive() {
    // eslint-disable-next-line no-console
    console.log('TODO: Connect#isActive is always true');
    return true;
  }
  /* eslint-enable class-methods-use-this */

  // For some reason the documentLifecycle promise wasn't ever hitting this
  // Check client & client#shutdown for more info
  handleWindowOffload(): void {
    window.addEventListener('beforeunload', () => this.shutdown.bind(this))
  }

  shutdown(): void {
    this.channels.forEach(channel => {
      channel.push('unsubscribe', { command: 'unsubscribe' })
    })
  }
}

export default Connection;
