import Subscription from './Subscription';
import Consumer from './Consumer';
import Imixin from './interfaces/mixin_interface';
import IChannel from './interfaces/channel_interface';

export default class Subscriptions {
  subscriptions: Array<Subscription>;

  consumer: Consumer;

  constructor(consumer: Consumer) {
    this.consumer = consumer;
    this.subscriptions = [];
  }

  create(channelName: IChannel, mixin: Imixin): Subscription {
    const channel = channelName;
    const params = typeof channel === 'object' ? channel : { channel };
    const subscription = new Subscription(this.consumer, params, mixin);
    return this.add(subscription);
  }

  add(subscription: Subscription): Subscription {
    this.subscriptions.push(subscription);
    this.consumer.ensureActiveConnection(); // What is this doing?
    this.notify(subscription, 'initialized');
    this.joinChannel(subscription);
    return subscription;
  }

  remove(subscription: Subscription): Subscription {
    this.forget(subscription);
    if (!this.findAll(subscription.identifier).length) {
      this.sendCommand(subscription, 'unsubscribe');
    }
    return subscription;
  }

  reject(identifier: Array<any>): Subscription[] {
    return this.findAll(identifier).map((subscription) => {
      this.forget(subscription);
      this.notify(subscription, 'rejected');
      return subscription;
    });
  }

  forget(subscription: Subscription): Subscription {
    this.subscriptions = this.subscriptions.filter((s) => s !== subscription);
    return subscription;
  }

  findAll(identifier): Subscription[] {
    return this.subscriptions.filter((s) => s.identifier === identifier);
  }

  reload(): void[] {
    return this.subscriptions.map((subscription) =>
      this.sendCommand(subscription, 'subscribe')
    );
  }

  notifyAll(callbackName, ...args) {
    return this.subscriptions.map((subscription) =>
      this.notify(subscription, callbackName, ...args)
    );
  }

  notify(subscription: Subscription, callbackName, ...args) {
    let subscriptions;
    if (typeof subscription === 'string') {
      subscriptions = this.findAll(subscription);
    } else {
      subscriptions = [subscription];
    }

    return subscriptions.map((sub) =>
      typeof sub[callbackName] === 'function'
        ? sub[callbackName](...args)
        : undefined
    );
  }

  sendCommand(subscription: Subscription, command: string) {
    const { identifier, channel } = subscription;
    return this.consumer.send({ command, identifier, channel });
  }

  joinChannel(subscription: Subscription) {
    return this.consumer.joinChannel(subscription);
  }
}
