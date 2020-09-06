import Client from './Client';
import IClient from './interfaces/client_interface';

export function createClient(options: IClient): Client {
  return new Client(options);
}

export default createClient;
