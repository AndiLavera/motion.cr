import Amber from 'amber';
import Consumer from './Consumer';
import Subscriptions from './Subscriptions';
// Encapsulate the cable connection held by the consumer.
// This is an internal class not intended for direct user manipulation.

const { indexOf } = [];

class Connection {
  socket: Amber.Socket

  consumer: Consumer

  subscriptions: Subscriptions

  constructor(consumer) {
    this.socket = new Amber.Socket('/cable');
    this.connection_promise = this.open.call(this);
    this.consumer = consumer;
    this.subscriptions = this.consumer.subscriptions;
    this.monitor = null; // new ConnectionMonitor(this)
    this.disconnected = true;
    this.channel;
    this.reopenDelay = 500;
  }

  send(data) {
    this.connection_promise.then(() => {
      console.log(data);
      this.channel.push('message_new', data);
    });
  }

  join_channel(data) {
    this.connection_promise.then(() => {
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

  // reopen() {
  //   logger.log(`Reopening WebSocket, current state is ${this.getState()}`)
  //   if (this.isActive()) {
  //     try {
  //       return this.close()
  //     } catch (error) {
  //       logger.log("Failed to reopen WebSocket", error)
  //     }
  //     finally {
  //       logger.log(`Reopening WebSocket in ${this.constructor.reopenDelay}ms`)
  //       setTimeout(this.open, this.constructor.reopenDelay)
  //     }
  //   } else {
  //     return this.open()
  //   }
  // }

  // getProtocol() {
  //   if (this.webSocket) {
  //     return this.webSocket.protocol
  //   }
  // }

  // isOpen() {
  //   return this.isState("open")
  // }

  isActive() {
    console.log('TODO: Connect#isActive is always true');
    return true;
  }

  // // Private

  // isProtocolSupported() {
  //   return indexOf.call(supportedProtocols, this.getProtocol()) >= 0
  // }

  // isState(...states) {
  //   return indexOf.call(states, this.getState()) >= 0
  // }

  // getState() {
  //   if (this.webSocket) {
  //     for (let state in adapters.WebSocket) {
  //       if (adapters.WebSocket[state] === this.webSocket.readyState) {
  //         return state.toLowerCase()
  //       }
  //     }
  //   }
  //   return null
  // }

  // installEventHandlers() {
  //   for (let eventName in this.events) {
  //     const handler = this.events[eventName].bind(this)
  //     this.webSocket[`on${eventName}`] = handler
  //   }
  // }

  // uninstallEventHandlers() {
  //   for (let eventName in this.events) {
  //     this.webSocket[`on${eventName}`] = function () { }
  //   }
  // }
}

// Connection.prototype.events = {
//   message(event) {
//     if (!this.isProtocolSupported()) { return }
//     const { identifier, message, reason, reconnect, type } = JSON.parse(event.data)
//     switch (type) {
//       case message_types.welcome:
//         this.monitor.recordConnect()
//         return this.subscriptions.reload()
//       case message_types.disconnect:
//         logger.log(`Disconnecting. Reason: ${reason}`)
//         return this.close({ allowReconnect: reconnect })
//       case message_types.ping:
//         return this.monitor.recordPing()
//       case message_types.confirmation:
//         return this.subscriptions.notify(identifier, "connected")
//       case message_types.rejection:
//         return this.subscriptions.reject(identifier)
//       default:
//         return this.subscriptions.notify(identifier, "received", message)
//     }
//   },

//   open() {
//     logger.log(`WebSocket onopen event, using '${this.getProtocol()}' subprotocol`)
//     this.disconnected = false
//     if (!this.isProtocolSupported()) {
//       logger.log("Protocol is unsupported. Stopping monitor and disconnecting.")
//       return this.close({ allowReconnect: false })
//     }
//   },

//   close(event) {
//     logger.log("WebSocket onclose event")
//     if (this.disconnected) { return }
//     this.disconnected = true
//     this.monitor.recordDisconnect()
//     return this.subscriptions.notifyAll("disconnected",
//      { willAttemptReconnect: this.monitor.isRunning() })
//   },

//   error() {
//     logger.log("WebSocket onerror event")
//   }
// }

export default Connection;
