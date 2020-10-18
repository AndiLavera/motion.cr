import Channel from './Channel'

const STALE_CONNECTION_THRESHOLD_SECONDS = 100;
const SOCKET_POLLING_RATE = 10000;

/**
 * Returns a numeric value for the current time
 */
const now = (): number => new Date().getTime();

/**
 * Returns the difference between the current time and passed `time` in seconds
 * @param {Number|Date} time - A numeric time or date object
 */
const secondsSince = (time: number | Date): number => (now() - time) / 1000;

/**
 * Class for maintaining connection with server and maintaining channels list
 */
class Socket {
  endpoint: string;

  ws: WebSocket | null;

  channels: Channel[];

  lastPing: number;

  reconnectTries: number;

  attemptReconnect: boolean;

  pollingTimeout: number;

  /**
   * @param {String} endpoint - Websocket endpont used in routes.cr file
   */
  constructor(endpoint: string) {
    this.endpoint = endpoint;
    this.ws = null;
    this.channels = [];
    this.lastPing = now();
    this.reconnectTries = 0;
    this.attemptReconnect = true;
  }

  /**
   * Returns whether or not the last received ping has been past the threshold
   */
  _connectionIsStale(): boolean {
    return secondsSince(this.lastPing) > STALE_CONNECTION_THRESHOLD_SECONDS;
  }

  /**
   * Tries to reconnect to the websocket server using a recursive timeout
   */
  _reconnect(): void {
    clearTimeout(this.reconnectTimeout);
    this.reconnectTimeout = setTimeout(() => {
      this.reconnectTries++;
      this.connect(this.params);
      this._reconnect();
    }, this._reconnectInterval());
  }

  /**
   * Returns an incrementing timeout interval based around the number of reconnection retries
   */
  _reconnectInterval(): number {
    return [1000, 2000, 5000, 10000][this.reconnectTries] || 10000;
  }

  /**
   * Sets a recursive timeout to check if the connection is stale
   */
  _poll(): void {
    this.pollingTimeout = setTimeout(() => {
      if (this._connectionIsStale()) {
        this._reconnect();
      } else {
        this._poll();
      }
    }, SOCKET_POLLING_RATE);
  }

  /**
   * Clear polling timeout and start polling
   */
  _startPolling(): void {
    clearTimeout(this.pollingTimeout);
    this._poll();
  }

  /**
   * Sets `lastPing` to the curent time
   */
  _handlePing(): void {
    this.lastPing = now();
  }

  /**
   * Clears reconnect timeout, resets variables an starts polling
   */
  _reset(): void {
    clearTimeout(this.reconnectTimeout);
    this.reconnectTries = 0;
    this.attemptReconnect = true;
    this._startPolling();
  }

  /**
   * Connect the socket to the server, and binds to native ws functions
   * @param {Object} params - Optional parameters
   * @param {String} params.location
   * - Hostname to connect to, defaults to `window.location.hostname`
   * @param {String} parmas.port - Port to connect to, defaults to `window.location.port`
   * @param {String} params.protocol - Protocol to use, either 'wss' or 'ws'
   */
  connect(params: any): Promise<void> {
    this.params = params;

    const opts = {
      location: window.location.hostname,
      port: window.location.port,
      protocol: window.location.protocol === 'https:' ? 'wss:' : 'ws:',
    };

    if (params) {
      Object.assign(opts, params);
    }
    if (opts.port) {
      opts.location += `:${opts.port}`;
    }

    return new Promise((resolve, reject) => {
      this.ws = new WebSocket(
        `${opts.protocol}//${opts.location}${this.endpoint}`
      );
      this.ws.onmessage = (msg) => {
        this.handleMessage(msg);
      };
      this.ws.onclose = () => {
        if (this.attemptReconnect) {
          this._reconnect();
        }
      };
      this.ws.onopen = () => {
        this._reset();
        resolve();
      };
    });
  }

  /**
   * Closes the socket connection permanently
   */
  disconnect(): void {
    this.attemptReconnect = false;
    clearTimeout(this.pollingTimeout);
    clearTimeout(this.reconnectTimeout);
    this.ws.close();
  }

  /**
   * Adds a new channel to the socket channels list
   * @param {String} topic - Topic for the channel: `chat_room:123`
   */
  channel(topic: string): Channel {
    const channel = new Channel(topic, this);
    this.channels.push(channel);
    return channel;
  }

  /**
   * Message handler for messages received
   * @param {MessageEvent} msg - Message received from ws
   */
  handleMessage(msg: MessageEvent): void {
    if (msg.data === 'ping') {
      return this._handlePing();
    }

    const parsed_msg = JSON.parse(msg.data);
    this.channels.forEach((channel) => {
      if (channel.topic === parsed_msg.topic) {
        channel.handleMessage(parsed_msg);
      }
    });
  }
}

export default Socket