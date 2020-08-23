import Consumer from './Consumer';
import Imixin from './interfaces/mixin_interface';
import ISubscriptionPayload from './interfaces/subscription_payload_interface';

const extend = function (object: any, properties: any) {
  if (properties != null) {
    for (const key in properties) {
      const value = properties[key];
      object[key] = value;
    }
  }
  return object;
};

export default class Subscription {
  consumer: Consumer

  identifier: string

  channel: string

  constructor(consumer: Consumer, params: any = {}, mixin: Imixin) {
    this.consumer = consumer;
    this.channel = params.channel;
    this.identifier = params;
    extend(this, mixin);
  }

  // Perform a channel action with the optional data passed as an attribute
  perform(data: ISubscriptionPayload) {
    return this.send(data);
  }

  send(data: ISubscriptionPayload) {
    return this.consumer.send({
      command: 'process_motion',
      identifier: this.identifier,
      data,
    });
  }

  unsubscribe() {
    return this.consumer.subscriptions.remove(this);
  }
}
