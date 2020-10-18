import Socket from './Socket'

const EVENTS = {
  join: 'join',
  leave: 'leave',
  message: 'message',
};

/**
 * Class for channel related functions (joining, leaving, subscribing and sending messages)
 */
class Channel {
  topic: string;

  socket: Socket;

  onMessageHandlers: Array<string | Function>;

  /**
   * @param {String} topic - topic to subscribe to
   * @param {Socket} socket - A Socket instance
   */
  constructor(topic: string, socket: Socket) {
    this.topic = topic;
    this.socket = socket;
    this.onMessageHandlers = [];
  }

  /**
   * Join a channel, subscribe to all channels messages
   */
  join() {
    this.socket.ws.send(
      JSON.stringify({ event: EVENTS.join, topic: this.topic, ...arguments[0] })
    );
  }

  /**
   * Leave a channel, stop subscribing to channel messages
   */
  leave() {
    this.socket.ws.send(
      JSON.stringify({ event: EVENTS.leave, topic: this.topic })
    );
  }

  /**
   * Calls all message handlers with a matching subject
   */
  handleMessage(msg) {
    this.onMessageHandlers.forEach((handler) => {
      if (handler.subject === msg.subject) {
        handler.callback(msg.payload);
      }
    });
  }

  /**
   * Subscribe to a channel subject
   * @param {String} subject - subject to listen for: `msg:new`
   * @param {function} callback - callback function when a new message arrives
   */
  on(subject: string, callback: Function): void {
    this.onMessageHandlers.push({ subject, callback });
  }

  /**
   * Send a new message to the channel
   * @param {String} subject - subject to send message to: `msg:new`
   * @param {Object} payload - payload object: `{message: 'hello'}`
   */
  push(subject: string, payload: object):void {
    this.socket.ws.send(
      JSON.stringify({
        event: EVENTS.message,
        topic: this.topic,
        subject,
        payload,
      })
    );
  }
}

export default Channel