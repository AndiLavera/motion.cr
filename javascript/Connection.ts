import Amber from './Amber';
import Consumer from './Consumer';
import Subscriptions from './Subscriptions';
import Subscription from './Subscription';

class Connection {
  socket: Amber.Socket

  consumer: Consumer

  subscriptions: Subscriptions

  disconnected: boolean

  channel: string | undefined

  reopenDelay: number

  connectionPromise: Promise<any>

  constructor(consumer: Consumer) {
    this.socket = new Amber.Socket('/cable');
    this.connectionPromise = this.open.call(this);
    this.consumer = consumer;
    this.subscriptions = this.consumer.subscriptions;
    this.disconnected = true;
    this.channel = undefined;
    this.reopenDelay = 500;
  }

  send(data) {
    this.connectionPromise.then(() => {
      this.channel.push('message_new', data);
    });
  }

  joinChannel(data: Subscription) {
    this.connectionPromise.then(() => {
      data.connected();
      this.channel = this.socket.channel(data.channel);

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
}

export default Connection;