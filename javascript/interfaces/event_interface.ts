import ITarget from './target_interface';

export default interface IEvent {
  extraData: string | null;
  type: string;
  currentTarget: ITarget;
  target: ITarget;
  details: {};
}
