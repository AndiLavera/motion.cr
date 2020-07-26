import Consumer from './Consumer';
import Imixin from './interfaces/imixin';

const extend = function (object, properties) {
  if (properties != null) {
    for (const key in properties) {
      const value = properties[key];
      object[key] = value;
    }
  }
  return object;
};

interface ITarget {
  formData: {} | null
  tagName: string
  value: string
  attributes: {
    class: string
    "data-motion": string
  }
}

interface IEvent {
  extraData: string | null
  type: string
  currentTarget: ITarget
  target: ITarget
  details: {}
}

interface IPayload {
  name: string
  event: IEvent
}

export default class Subscription {
  consumer: Consumer

  identifier: string

  channel: string

  constructor(consumer: Consumer, params = {}, mixin: Imixin) {
    this.consumer = consumer;
    this.channel = params.channel;
    this.identifier = params;
    extend(this, mixin);
  }

  // Perform a channel action with the optional data passed as an attribute
  perform(data: IPayload) {
    return this.send(data);
  }

  send(data: IPayload) {
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
