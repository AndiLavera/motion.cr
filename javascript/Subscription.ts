import Consumer from './Consumer';

const extend = function (object, properties) {
  if (properties != null) {
    for (const key in properties) {
      const value = properties[key];
      object[key] = value;
    }
  }
  return object;
};

export default class Subscription {
  constructor(consumer, params = {}, mixin) {
    this.consumer = consumer;
    this.channel = params.channel;
    this.identifier = params;
    extend(this, mixin);
  }

  // Perform a channel action with the optional data passed as an attribute
  perform(data = {}) {
    return this.send(data);
  }

  send(data) {
    return this.consumer.send({
      command: 'process_motion',
      identifier: this.identifier,
      data,
    });
  }

  unsubscribe() {
    return this.consumer.subscriptions.remove(this);
  }

  consumer: Consumer

  identifier: string

  channel: string
}
