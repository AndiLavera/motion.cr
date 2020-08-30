export default interface IClient {
  getExtraDataForEvent: Function;
  logging: boolean;
  root: Document;
  shutdownBeforeUnload: boolean;
  keyAttribute: string;
  stateAttribute: string;
  motionAttribute: string;
}
